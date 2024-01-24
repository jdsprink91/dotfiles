return {
    "goolord/alpha-nvim",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Set header
        dashboard.section.header.val = {
            " ",
            "(`-').-> _  (`-')   (`-')   _     <-. (`-')_ <-.(`-')          (`-')  _      (`-')  _     <-. (`-')",
            "( OO)_   \\-.(OO )<-.(OO )  (_)       \\( OO) ) __( OO)   <-.    ( OO).-/     _(OO ) (_)       \\(OO )_",
            "(_)--\\_)  _.'    \\,------,) ,-(`-'),--./ ,--/ '-'. ,--.,--. )  (,------.,--.(_/,-.\\ ,-(`-'),--./  ,-.)",
            "/    _ / (_...--''|   /`. ' | ( OO)|   \\ |  | |  .'   /|  (`-') |  .---'\\   \\ / (_/ | ( OO)|   `.'   |",
            "\\_..`--. |  |_.' ||  |_.' | |  |  )|  . '|  |)|      /)|  |OO )(|  '--.  \\   /   /  |  |  )|  |'.'|  |",
            ".-._)   \\|  .___.'|  .   .'(|  |_/ |  |\\    | |  .   '(|  '__ | |  .--' _ \\     /_)(|  |_/ |  |   |  |",
            "\\       /|  |     |  |\\  \\  |  |'->|  | \\   | |  |\\   \\|     |' |  `---.\\-'\\   /    |  |'->|  |   |  |",
            " `-----' `--'     `--' '--' `--'   `--'  `--' `--' '--'`-----'  `------'    `-'     `--'   `--'   `--'",
        }

        dashboard.section.buttons.val = {
            dashboard.button("o", "🛢  > Oil", ":Oil<cr>"),
            dashboard.button("f", "📁  > Find File", ":Telescope find_files theme=dropdown previewer=false<cr>"),
            dashboard.button("g", "🔎  > Grep Search", ":Telescope live_grep theme=dropdown<cr>"),
            dashboard.button("l", "📌  > Load Last Session", ":SessionManager load_current_dir_session<cr>"),
            dashboard.button("s", "🔌  > Sync Plugins", ":Lazy sync<cr>"),
            dashboard.button("q", "🛑  > Quit Neovim", ":qa<cr>"),
        }

        -- Send config to alpha
        alpha.setup(dashboard.opts)
    end
}
