import { Injectable } from '@nestjs/common';
import { execSync } from 'child_process';

@Injectable()
export class AppService {
  getLatestChanges(): string {
    try {
      const latestChanges = execSync('git log -n 5 --pretty=format:"%h %s (%ar)" --abbrev-commit').toString();
      
      // Generate a nicely formatted HTML page
      return `
<!DOCTYPE html>
<html>
<head>
  <title>CalliVox API Server</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    h1 {
      color: #2c3e50;
      border-bottom: 2px solid #eee;
      padding-bottom: 10px;
    }
    h2 {
      color: #3498db;
      margin-top: 30px;
    }
    .card {
      background: #f9f9f9;
      border-radius: 8px;
      padding: 20px;
      margin: 20px 0;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    code {
      background: #f4f4f4;
      padding: 3px 5px;
      border-radius: 3px;
      font-family: monospace;
    }
    ul {
      padding-left: 25px;
    }
    li {
      margin-bottom: 8px;
    }
    .changes {
      font-family: monospace;
      white-space: pre-wrap;
      background: #f4f4f4;
      padding: 15px;
      border-radius: 5px;
      overflow-x: auto;
    }
    .endpoint {
      margin-bottom: 10px;
      padding: 12px;
      background: #e8f4fc;
      border-radius: 5px;
    }
    .method {
      font-weight: bold;
      color: #2980b9;
      display: inline-block;
      width: 80px;
    }
    .footer {
      margin-top: 40px;
      text-align: center;
      font-size: 14px;
      color: #7f8c8d;
      border-top: 1px solid #eee;
      padding-top: 20px;
    }
  </style>
</head>
<body>
  <h1>🔊 CalliVox API Server</h1>
  
  <div class="card">
    <p>Welcome to the CalliVox backend API server. This server provides authentication and data services for the CalliVox application.</p>
    <p>Server Status: <strong>Online</strong></p>
    <p>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></p>
  </div>

  <h2>📋 Available API Endpoints</h2>
  
  <div class="endpoint">
    <div><span class="method">POST</span> <code>/auth/apple/mobile</code></div>
    <div>Authenticate with Apple ID token from iOS app</div>
  </div>
  
  <div class="endpoint">
    <span class="method">GET</span> <code>/auth/apple/callback</code>
    <div>Apple Sign In web authentication callback</div>
  </div>
  
  <h2>🛠️ Configuration Status</h2>
  <ul>
    <li>Apple Authentication: <strong>${process.env.APPLE_CLIENT_ID && process.env.APPLE_TEAM_ID && process.env.APPLE_KEY_ID && process.env.APPLE_PRIVATE_KEY ? '✅ Configured' : '❌ Not Configured'}</strong></li>
    <li>JWT Authentication: <strong>${process.env.JWT_SECRET ? '✅ Configured' : '❌ Using default secret (not secure for production)'}</strong></li>
  </ul>

  <h2>🔄 Recent Changes</h2>
  <div class="changes">${latestChanges.replace(/\n/g, '<br>')}</div>
  
  <div class="footer">
    <p>CalliVox API Server © ${new Date().getFullYear()}</p>
    <p>Server Time: ${new Date().toLocaleString()}</p>
  </div>
</body>
</html>
      `;
    } catch (error) {
      return `
<!DOCTYPE html>
<html>
<head>
  <title>CalliVox API Server</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    h1 {
      color: #2c3e50;
      border-bottom: 2px solid #eee;
      padding-bottom: 10px;
    }
    .card {
      background: #f9f9f9;
      border-radius: 8px;
      padding: 20px;
      margin: 20px 0;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
  </style>
</head>
<body>
  <h1>🔊 CalliVox API Server</h1>
  
  <div class="card">
    <p>Welcome to the CalliVox backend API server. This server provides authentication and data services for the CalliVox application.</p>
    <p>Server Status: <strong>Online</strong></p>
    <p>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></p>
    <p>Unable to retrieve latest changes.</p>
  </div>
</body>
</html>
      `;
    }
  }
}
