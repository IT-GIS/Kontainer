import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Sistem Kelaikan Peti Kemas Terintegrasi",
  description: "Sistem pengelolaan pemeriksaan dan dokumen Kelaikan peti kemas.",
  icons: {
    icon: "/images/gift-logo.png",
    shortcut: "/favicon.ico"
  }
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="id">
      <body>
        <Providers>
          <div className="page-shell">{children}</div>
        </Providers>
      </body>
    </html>
  );
}
