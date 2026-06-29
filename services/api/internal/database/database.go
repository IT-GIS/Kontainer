package database

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/google/uuid"
)

var ErrNoRows = sql.ErrNoRows

type FieldDescription struct{ Name string }
type Row interface{ Scan(dest ...any) error }
type Rows interface {
	Close()
	Err() error
	FieldDescriptions() []FieldDescription
	Next() bool
	Scan(dest ...any) error
	Values() ([]any, error)
}
type CommandTag struct{ result sql.Result }

func (c CommandTag) RowsAffected() int64 {
	if c.result == nil {
		return 0
	}
	n, _ := c.result.RowsAffected()
	return n
}

type Tx interface {
	Exec(context.Context, string, ...any) (CommandTag, error)
	Query(context.Context, string, ...any) (Rows, error)
	QueryRow(context.Context, string, ...any) Row
	Commit(context.Context) error
	Rollback(context.Context) error
}

type DB struct{ Pool *Pool }
type Pool struct{ db *sql.DB }

func Connect(ctx context.Context, dsn string) (*DB, error) {
	if strings.TrimSpace(dsn) == "" {
		return nil, errors.New("DATABASE_URL is required")
	}
	connection, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, fmt.Errorf("open MySQL database: %w", err)
	}
	connection.SetMaxOpenConns(10)
	connection.SetMaxIdleConns(2)
	connection.SetConnMaxLifetime(time.Hour)
	connection.SetConnMaxIdleTime(30 * time.Minute)
	if err := connection.PingContext(ctx); err != nil {
		connection.Close()
		return nil, fmt.Errorf("ping MySQL database: %w", err)
	}
	return &DB{Pool: &Pool{db: connection}}, nil
}
func (db *DB) Close() {
	if db != nil && db.Pool != nil && db.Pool.db != nil {
		_ = db.Pool.db.Close()
	}
}

func (p *Pool) Exec(ctx context.Context, query string, args ...any) (CommandTag, error) {
	query, args = prepare(query, args)
	result, err := p.db.ExecContext(ctx, query, args...)
	return CommandTag{result}, err
}
func (p *Pool) Query(ctx context.Context, query string, args ...any) (Rows, error) {
	return queryContext(ctx, p.db, query, args...)
}
func (p *Pool) QueryRow(ctx context.Context, query string, args ...any) Row {
	return queryRowContext(ctx, p.db, query, args...)
}
func (p *Pool) Begin(ctx context.Context) (Tx, error) {
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	return &mysqlTx{tx}, nil
}

type mysqlTx struct{ tx *sql.Tx }

func (t *mysqlTx) Exec(ctx context.Context, query string, args ...any) (CommandTag, error) {
	query, args = prepare(query, args)
	result, err := t.tx.ExecContext(ctx, query, args...)
	return CommandTag{result}, err
}
func (t *mysqlTx) Query(ctx context.Context, query string, args ...any) (Rows, error) {
	return queryContext(ctx, t.tx, query, args...)
}
func (t *mysqlTx) QueryRow(ctx context.Context, query string, args ...any) Row {
	return queryRowContext(ctx, t.tx, query, args...)
}
func (t *mysqlTx) Commit(context.Context) error   { return t.tx.Commit() }
func (t *mysqlTx) Rollback(context.Context) error { return t.tx.Rollback() }

type queryer interface {
	ExecContext(context.Context, string, ...any) (sql.Result, error)
	QueryContext(context.Context, string, ...any) (*sql.Rows, error)
	QueryRowContext(context.Context, string, ...any) *sql.Row
}

func queryContext(ctx context.Context, db queryer, query string, args ...any) (Rows, error) {
	base, returning, ok := splitReturning(query)
	if ok {
		rows, err := executeReturning(ctx, db, base, returning, args...)
		if err != nil {
			return nil, err
		}
		return newRows(rows)
	}
	query, args = prepare(query, args)
	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	return newRows(rows)
}
func queryRowContext(ctx context.Context, db queryer, query string, args ...any) Row {
	base, returning, ok := splitReturning(query)
	if ok {
		rows, err := executeReturning(ctx, db, base, returning, args...)
		if err != nil {
			return errorRow{err}
		}
		return &rowsRow{rows}
	}
	query, args = prepare(query, args)
	return db.QueryRowContext(ctx, query, args...)
}

type errorRow struct{ err error }

func (r errorRow) Scan(...any) error { return r.err }

type rowsRow struct{ rows *sql.Rows }

func (r *rowsRow) Scan(dest ...any) error {
	defer r.rows.Close()
	if !r.rows.Next() {
		if err := r.rows.Err(); err != nil {
			return err
		}
		return sql.ErrNoRows
	}
	return r.rows.Scan(dest...)
}

type mysqlRows struct {
	rows   *sql.Rows
	fields []FieldDescription
}

func newRows(rows *sql.Rows) (*mysqlRows, error) {
	columns, err := rows.Columns()
	if err != nil {
		rows.Close()
		return nil, err
	}
	fields := make([]FieldDescription, len(columns))
	for i, column := range columns {
		fields[i] = FieldDescription{Name: column}
	}
	return &mysqlRows{rows, fields}, nil
}
func (r *mysqlRows) Close()                                { _ = r.rows.Close() }
func (r *mysqlRows) Err() error                            { return r.rows.Err() }
func (r *mysqlRows) FieldDescriptions() []FieldDescription { return r.fields }
func (r *mysqlRows) Next() bool                            { return r.rows.Next() }
func (r *mysqlRows) Scan(dest ...any) error                { return r.rows.Scan(dest...) }
func (r *mysqlRows) Values() ([]any, error) {
	values := make([]any, len(r.fields))
	pointers := make([]any, len(values))
	for i := range values {
		pointers[i] = &values[i]
	}
	if err := r.rows.Scan(pointers...); err != nil {
		return nil, err
	}
	for i, value := range values {
		if bytes, ok := value.([]byte); ok {
			values[i] = string(bytes)
		}
	}
	return values, nil
}

var (
	dollarParameter = regexp.MustCompile(`\$([0-9]+)`)
	returningWord   = regexp.MustCompile(`(?i)\s+RETURNING\s+`)
	insertPattern   = regexp.MustCompile(`(?is)^\s*INSERT\s+(?:IGNORE\s+)?INTO\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)\s*VALUES\s*\((.*)\)\s*$`)
	updatePattern   = regexp.MustCompile(`(?is)^\s*UPDATE\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+SET\s+.*?\s+WHERE\s+(.+)$`)
)

func prepare(query string, args []any) (string, []any) {
	query = strings.TrimSpace(query)
	if !dollarParameter.MatchString(query) {
		return query, normalizeArgs(args)
	}
	bound := make([]any, 0, len(args))
	query = dollarParameter.ReplaceAllStringFunc(query, func(value string) string {
		index, _ := strconv.Atoi(value[1:])
		if index > 0 && index <= len(args) {
			bound = append(bound, normalizeArg(args[index-1]))
		}
		return "?"
	})
	return query, bound
}
func normalizeArgs(args []any) []any {
	result := make([]any, len(args))
	for i, arg := range args {
		result[i] = normalizeArg(arg)
	}
	return result
}
func normalizeArg(value any) any {
	switch typed := value.(type) {
	case uuid.UUID:
		return typed.String()
	case *uuid.UUID:
		if typed == nil {
			return nil
		}
		return typed.String()
	default:
		return value
	}
}

func splitReturning(query string) (string, string, bool) {
	location := returningWord.FindStringIndex(query)
	if location == nil {
		return query, "", false
	}
	return strings.TrimSpace(query[:location[0]]), strings.TrimSpace(query[location[1]:]), true
}

func executeReturning(ctx context.Context, db queryer, base, returning string, args ...any) (*sql.Rows, error) {
	prepared, bound := prepare(base, args)
	returning, _ = prepare(returning, nil)
	if match := insertPattern.FindStringSubmatch(prepared); match != nil {
		table, id := match[1], uuid.NewString()
		hasID := false
		for _, column := range strings.Split(match[2], ",") {
			if strings.EqualFold(strings.TrimSpace(column), "id") {
				hasID = true
				break
			}
		}
		if !hasID {
			prepared = fmt.Sprintf("INSERT INTO %s (id, %s) VALUES (?, %s)", table, match[2], match[3])
			bound = append([]any{id}, bound...)
		}
		if _, err := db.ExecContext(ctx, prepared, bound...); err != nil {
			return nil, err
		}
		return db.QueryContext(ctx, fmt.Sprintf("SELECT %s FROM %s WHERE id = ?", returning, table), id)
	}
	if match := updatePattern.FindStringSubmatch(prepared); match != nil {
		whereIndex := strings.Index(strings.ToUpper(prepared), " WHERE ")
		if whereIndex < 0 {
			return nil, errors.New("MySQL RETURNING compatibility requires a WHERE clause")
		}
		whereArgs := bound[strings.Count(prepared[:whereIndex], "?"):]
		if _, err := db.ExecContext(ctx, prepared, bound...); err != nil {
			return nil, err
		}
		return db.QueryContext(ctx, fmt.Sprintf("SELECT %s FROM %s WHERE %s", returning, match[1], match[2]), whereArgs...)
	}
	return nil, errors.New("unsupported MySQL RETURNING statement")
}
