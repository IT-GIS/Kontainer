import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Sistem Kelayakan Peti Kemas Terintegrasi",
  description: "Web MVP for container survey operations, review, reports, and finance."
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <div className="page-shell">{children}</div>
        </Providers>
      </body>
    </html>
  );
}
