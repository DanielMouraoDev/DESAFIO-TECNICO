import { NextResponse, type NextRequest } from "next/server";

// Protect all /dashboard routes using the presence of the access token cookie.
// Note: middleware cannot read localStorage, so we rely on the client to keep
// localStorage and the cookie in sync after login.
export function middleware(req: NextRequest) {
  const accessToken = req.cookies.get("mpedu_access")?.value;

  if (!accessToken) {
    const url = req.nextUrl.clone();
    url.pathname = "/login";
    url.searchParams.set("from", req.nextUrl.pathname);
    return NextResponse.redirect(url);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*"],
};

