export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-zinc-50 dark:bg-black">
      <main className="w-full max-w-lg px-6">
        <h1 className="text-2xl font-semibold text-black dark:text-zinc-50">Meu Projeto Edu</h1>
        <p className="mt-2 text-zinc-600 dark:text-zinc-400">
          Use the auth pages below. Access to <code>/dashboard</code> is protected.
        </p>

        <div className="mt-6 flex gap-3">
          <a
            href="/login"
            className="inline-flex items-center justify-center rounded-full bg-black text-white h-11 px-5 dark:bg-zinc-800"
          >
            Login
          </a>
          <a
            href="/dashboard"
            className="inline-flex items-center justify-center rounded-full border border-black/10 text-black h-11 px-5 dark:text-zinc-50 dark:border-white/20"
          >
            Dashboard
          </a>
        </div>
      </main>
    </div>
  );
}
