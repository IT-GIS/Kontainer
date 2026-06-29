"use client";

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { apiData, apiRequest } from "@/lib/api-client";
import type { CurrentUser, LoginResult } from "@/types/auth";

type AuthContextValue = {
  user: CurrentUser | null;
  accessToken: string | null;
  refreshToken: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  reloadMe: () => Promise<void>;
};

const ACCESS_KEY = "container_survey_access_token";
const REFRESH_KEY = "container_survey_refresh_token";

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<CurrentUser | null>(null);
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const clearSession = useCallback(() => {
    localStorage.removeItem(ACCESS_KEY);
    localStorage.removeItem(REFRESH_KEY);
    setAccessToken(null);
    setRefreshToken(null);
    setUser(null);
  }, []);

  const persistSession = useCallback((nextAccessToken: string, nextRefreshToken: string, nextUser?: CurrentUser) => {
    localStorage.setItem(ACCESS_KEY, nextAccessToken);
    localStorage.setItem(REFRESH_KEY, nextRefreshToken);
    setAccessToken(nextAccessToken);
    setRefreshToken(nextRefreshToken);
    if (nextUser) {
      setUser(nextUser);
    }
  }, []);

  const loadMe = useCallback(async (token: string) => {
    const nextUser = await apiData<CurrentUser>("/me", { accessToken: token });
    setUser(nextUser);
  }, []);

  const reloadMe = useCallback(async () => {
    if (!accessToken) {
      return;
    }
    await loadMe(accessToken);
  }, [accessToken, loadMe]);

  useEffect(() => {
    let active = true;
    async function bootstrapSession() {
      const storedAccess = localStorage.getItem(ACCESS_KEY);
      const storedRefresh = localStorage.getItem(REFRESH_KEY);
      if (!storedAccess) {
        if (active) {
          setIsLoading(false);
        }
        return;
      }
      if (active) {
        setAccessToken(storedAccess);
        setRefreshToken(storedRefresh);
      }
      try {
        await loadMe(storedAccess);
      } catch {
        if (active) {
          clearSession();
        }
      } finally {
        if (active) {
          setIsLoading(false);
        }
      }
    }
    void bootstrapSession();
    return () => {
      active = false;
    };
  }, [clearSession, loadMe]);

  const login = useCallback(
    async (email: string, password: string) => {
      const result = await apiData<LoginResult>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ email, password })
      });
      persistSession(result.access_token, result.refresh_token, result.user);
    },
    [persistSession]
  );

  const logout = useCallback(async () => {
    const token = accessToken;
    const refresh = refreshToken;
    clearSession();
    if (token) {
      await apiRequest("/auth/logout", {
        method: "POST",
        accessToken: token,
        body: JSON.stringify({ refresh_token: refresh })
      }).catch(() => undefined);
    }
  }, [accessToken, clearSession, refreshToken]);

  const value = useMemo(
    () => ({ user, accessToken, refreshToken, isLoading, login, logout, reloadMe }),
    [accessToken, isLoading, login, logout, refreshToken, reloadMe, user]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used inside AuthProvider");
  }
  return context;
}