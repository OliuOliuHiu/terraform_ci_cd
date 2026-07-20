import { Injectable } from '@nestjs/common';

// ---------------------------------------------------------------------------
// SỬA THÔNG TIN CỦA BẠN Ở ĐÂY — phần HTML/CSS bên dưới không cần đụng tới.
// ---------------------------------------------------------------------------
const profile = {
  name: 'Lazy Guy(OliuHiu)',
  title: 'DevOps Engineer',
  initials: 'DH',
  bio: 'Mình xây dựng và vận hành hạ tầng tự động: Terraform dựng VPC trên AWS, Ansible cấu hình server, Jenkins build & deploy container.',
  skills: [
    'Terraform',
    'Ansible',
    'Jenkins',
    'Docker',
    'AWS',
    'NestJS',
    'Nginx',
    'Prometheus',
  ],
  links: [
    { label: 'GitHub', url: 'https://github.com/OliuOliuHiu' },
    // Bỏ comment dòng dưới nếu muốn CÔNG KHAI email (trang này ai cũng xem được):
    // { label: 'Email', url: 'mailto:ban@example.com' },
  ],
};

// Thời điểm tiến trình khởi động = thời điểm container được deploy. Hiện ở footer
// để biết ngay bản đang chạy có phải bản vừa deploy hay không.
const startedAt = new Date();

@Injectable()
export class AppService {
  getProfile() {
    return profile;
  }

  getProfilePage(): string {
    const skills = profile.skills
      .map((s) => '<li class="chip">' + escapeHtml(s) + '</li>')
      .join('');

    const links = profile.links
      .map(
        (l) =>
          '<a class="link" href="' +
          escapeHtml(l.url) +
          '" rel="noopener">' +
          escapeHtml(l.label) +
          '</a>',
      )
      .join('');

    return `<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(profile.name)}</title>
<style>
  /* CSS nhúng thẳng, KHÔNG dùng file rời: nginx proxy /app có cắt prefix nên
     đường dẫn tới asset ngoài sẽ lệch. Nhúng inline là chắc ăn nhất. */
  :root {
    --bg: #f6f7f9;
    --card: #ffffff;
    --text: #1a1d21;
    --muted: #6b7280;
    --accent: #2563eb;
    --chip-bg: #eef2ff;
    --chip-text: #3730a3;
    --border: #e5e7eb;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #0f1115;
      --card: #171a21;
      --text: #e8eaed;
      --muted: #9aa3af;
      --accent: #60a5fa;
      --chip-bg: #1e2537;
      --chip-text: #93b4fc;
      --border: #262b36;
    }
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 24px;
    background: var(--bg);
    color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
  }
  .card {
    width: 100%;
    max-width: 640px;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 40px;
    box-shadow: 0 1px 3px rgba(0,0,0,.06), 0 12px 32px rgba(0,0,0,.05);
  }
  .head { display: flex; align-items: center; gap: 20px; }
  .avatar {
    flex: 0 0 auto;
    width: 72px; height: 72px;
    border-radius: 50%;
    display: grid; place-items: center;
    background: var(--accent);
    color: #fff;
    font-size: 26px; font-weight: 600;
    letter-spacing: .5px;
  }
  h1 { margin: 0; font-size: 26px; line-height: 1.25; }
  .title { margin: 2px 0 0; color: var(--accent); font-weight: 500; }
  .bio { margin: 24px 0 0; color: var(--muted); }
  h2 {
    margin: 32px 0 12px;
    font-size: 12px; font-weight: 600;
    text-transform: uppercase; letter-spacing: .08em;
    color: var(--muted);
  }
  .chips { display: flex; flex-wrap: wrap; gap: 8px; margin: 0; padding: 0; list-style: none; }
  .chip {
    background: var(--chip-bg); color: var(--chip-text);
    padding: 5px 12px; border-radius: 999px;
    font-size: 13px; font-weight: 500;
  }
  .links { display: flex; flex-wrap: wrap; gap: 10px; }
  .link {
    display: inline-block;
    padding: 9px 18px;
    border: 1px solid var(--border); border-radius: 8px;
    color: var(--text); text-decoration: none;
    font-size: 14px; font-weight: 500;
    transition: border-color .15s, color .15s;
  }
  .link:hover { border-color: var(--accent); color: var(--accent); }
  footer {
    margin-top: 36px; padding-top: 20px;
    border-top: 1px solid var(--border);
    font-size: 12.5px; color: var(--muted);
  }
  @media (max-width: 480px) {
    .card { padding: 28px 22px; }
    .head { flex-direction: column; align-items: flex-start; gap: 14px; }
  }
</style>
</head>
<body>
  <main class="card">
    <div class="head">
      <div class="avatar">${escapeHtml(profile.initials)}</div>
      <div>
        <h1>${escapeHtml(profile.name)}</h1>
        <p class="title">${escapeHtml(profile.title)}</p>
      </div>
    </div>

    <p class="bio">${escapeHtml(profile.bio)}</p>

    <h2>Kỹ năng</h2>
    <ul class="chips">${skills}</ul>

    <h2>Liên hệ</h2>
    <div class="links">${links}</div>

    <footer>
      Chạy bằng NestJS trong Docker · deploy lúc ${escapeHtml(startedAt.toISOString())}
    </footer>
  </main>
</body>
</html>`;
  }
}

// Chặn HTML injection: sau này profile có lấy từ nguồn ngoài thì vẫn an toàn.
function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
