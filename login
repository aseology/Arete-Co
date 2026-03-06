<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login | Arete</title>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <style>
        body { 
            font-family: -apple-system, system-ui, sans-serif; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0;
            background: #f4f7f6; 
        }
        #login-form { 
            background: white; 
            padding: 40px; 
            border-radius: 12px; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.05); 
            width: 100%;
            max-width: 320px; 
            text-align: center;
        }
        h2 { margin-top: 0; color: #333; }
        input { 
            width: 100%; 
            padding: 12px; 
            margin: 10px 0; 
            border: 1px solid #ddd; 
            border-radius: 6px; 
            box-sizing: border-box; 
            font-size: 16px;
        }
        button { 
            width: 100%; 
            padding: 12px; 
            background: #1a1a1a; 
            color: white; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 16px;
            font-weight: 600;
            transition: background 0.2s;
        }
        button:hover { background: #000; }
        .error-msg { color: #ff4757; font-size: 14px; margin-top: 10px; display: none; }
    </style>
</head>
<body>

<div id="login-form">
  <h2>Admin Login</h2>
  <input type="email" id="email" placeholder="Email" required>
  <input type="password" id="password" placeholder="Password" required>
  <button onclick="signIn()">Login</button>
  <div id="error-display" class="error-msg"></div>
</div>

<script>
  // Initializing Supabase with your project details
  const supabaseUrl = 'https://etsztcmmyhephvrrdpyp.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0c3p0Y21teWhlcGh2cnJkcHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3NDAxNzYsImV4cCI6MjA4ODMxNjE3Nn0.1bT6mjYxep88pnibQyyWikg2HtTUF8at5NGPXB3VmzI'
';
  const supabase = supabase.createClient(supabaseUrl, supabaseKey);

  async function signIn() {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const errorDisplay = document.getElementById('error-display');
    
    // Attempt to sign in
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    
    if (error) {
      errorDisplay.innerText = error.message;
      errorDisplay.style.display = 'block';
    } else {
      // Redirecting to your dashboard in the OPS folder
      window.location.href = "/OPS/dashboard.html"; 
    }
  }

  // Allow pressing "Enter" to log in
  document.addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
      signIn();
    }
  });
</script>

</body>
</html>