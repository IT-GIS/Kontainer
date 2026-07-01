"use client";

import Image from "next/image";
import { Loader2, Lock, Mail } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { FormEvent, Suspense, useState } from "react";
import { useAuth } from "@/hooks/use-auth";

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="source-login-page"><Loader2 className="source-login-loader" size={28} /></div>}>
      <LoginForm />
    </Suspense>
  );
}

function LoginForm() {
  const { login } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();
  const [email, setEmail] = useState("superadmin@gift.local");
  const [password, setPassword] = useState("password");
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setIsSubmitting(true);
    try {
      await login(email, password);
      router.replace(searchParams.get("next") || "/dashboard");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login gagal.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="source-login-page">
      <section className="source-login-card" aria-labelledby="login-title">
        <header className="source-login-heading">
          <Image className="source-login-logo" src="/images/gift-logo.png" alt="GIFT Logo" width={72} height={72} priority />
          <div>
            <h1 id="login-title">Sistem Kelayakan Peti Kemas Terintegrasi</h1>
            <p>PT. Global Inspeksi Sertifikasi</p>
          </div>
        </header>

        <form className="source-login-form" onSubmit={handleSubmit}>
          <label className="source-login-control">
            <span>Email</span>
            <div className="source-login-input-wrap">
              <Mail size={17} aria-hidden="true" />
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                autoComplete="email"
                placeholder="nama@ptgis.local"
                required
              />
            </div>
          </label>

          <label className="source-login-control">
            <span>Password</span>
            <div className="source-login-input-wrap">
              <Lock size={17} aria-hidden="true" />
              <input
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                autoComplete="current-password"
                placeholder="••••••••"
                required
              />
            </div>
          </label>

          <div className="source-login-meta">
            <label className="source-login-remember">
              <input type="checkbox" defaultChecked />
              <span>Ingat saya</span>
            </label>
            <span className="source-login-forgot" aria-disabled="true">Lupa password?</span>
          </div>

          {error ? <div className="source-login-alert" role="alert">{error}</div> : null}

          <button className="source-login-submit" type="submit" disabled={isSubmitting}>
            {isSubmitting ? <><Loader2 className="source-login-loader" size={17} /><span>Memproses...</span></> : <span>Masuk</span>}
          </button>
        </form>
      </section>
    </main>
  );
}
