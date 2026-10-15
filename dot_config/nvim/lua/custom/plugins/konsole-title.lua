-- Set the Konsole tab title to the current project name (the auto-cd'd
-- root from project.nvim), via Konsole's D-Bus session interface.
--
-- Why D-Bus instead of vim.opt.title: this Konsole profile uses the default
-- tab title format (%d : %n), which ignores OSC 2 escape sequences. OSC 2
-- only changes the *window* title. setTitle(1, ...) renames the actual tab.

return {
  {
    -- No plugin to install; this is just a config module driven by autocmds.
    name = 'konsole-title',
    dir = vim.fn.stdpath 'config', -- satisfy lazy.nvim without fetching
    lazy = false,
    init = function()
      -- Only bother inside Konsole.
      if not vim.env.KONSOLE_DBUS_SERVICE or not vim.env.KONSOLE_DBUS_SESSION then
        return
      end

      local service = vim.env.KONSOLE_DBUS_SERVICE
      local session = vim.env.KONSOLE_DBUS_SESSION

      local function dbus(args)
        return vim.system(vim.list_extend({ 'qdbus6', service, session }, args))
      end

      -- Read the live, format-derived tab title ("cwd : program").
      local function get_tab_title()
        local out = dbus({ 'org.kde.konsole.Session.title', '1' }):wait()
        return vim.trim(out.stdout or '')
      end

      local function set_tab_title(title)
        dbus({ 'org.kde.konsole.Session.setTitle', '1', title }):wait()
      end

      local function project_name()
        -- Use project.nvim's root once it's loaded; until then (VimEnter runs
        -- before lazy loads it) the cwd is already the project root anyway,
        -- because project.nvim chdirs on the file you opened.
        local ok, project = pcall(require, 'project_nvim')
        local root = ok and type(project.get_project_root) == 'function' and project.get_project_root() or nil
        local dir = (root and root ~= '') and root or vim.fn.getcwd()
        return vim.fn.fnamemodify(dir, ':t')
      end

      local group = vim.api.nvim_create_augroup('konsole-tab-title', { clear = true })

      -- Capture the pre-nvim title once, then start overriding it.
      local saved_title
      vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        once = true,
        callback = function()
          saved_title = get_tab_title()
          set_tab_title(project_name())
        end,
      })

      -- Update whenever project.nvim (or :cd) changes the directory.
      vim.api.nvim_create_autocmd('DirChanged', {
        group = group,
        callback = function()
          set_tab_title(project_name())
        end,
      })

      -- Restore exactly the title the tab had before nvim ran.
      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        callback = function()
          if saved_title and saved_title ~= '' then
            set_tab_title(saved_title)
          end
        end,
      })
    end,
  },
}
