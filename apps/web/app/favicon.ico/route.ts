export function GET(request: Request) {
  return Response.redirect(new URL("/images/gift-logo.png", request.url), 307);
}
