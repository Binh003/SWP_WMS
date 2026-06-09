    </main>
  </div>
</div>
<script>
  (function() {
    const toggleBtn = document.getElementById('sidebarToggle');
    const layout = document.getElementById('homeLayout');
    const shell = document.getElementById('homeShell');
    
    if (toggleBtn && layout && shell) {
      toggleBtn.addEventListener('click', function() {
        const isCollapsed = layout.classList.toggle('home-layout--collapsed');
        shell.classList.toggle('home-shell--collapsed', isCollapsed);
        localStorage.setItem('sidebar-collapsed', isCollapsed);
      });
    }
  })();
</script>
</body>
</html>
