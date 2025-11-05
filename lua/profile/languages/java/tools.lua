-- added-by-agent: java-setup 20251020-163000
-- mason: jdtls
-- manual: java-debug and vscode-java-test bundle build steps

local M = {}

-- Helper function to run commands in a terminal buffer
local function run_in_term(cmd, title)
    vim.cmd("botright new")
    local buf = vim.api.nvim_get_current_buf()
    local chan = vim.api.nvim_open_term(buf, {})
    vim.api.nvim_buf_set_name(buf, title)
    vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            data = table.concat(data, "\n")
            vim.api.nvim_chan_send(chan, data)
        end,
        on_stderr = function(_, data)
            data = table.concat(data, "\n")
            vim.api.nvim_chan_send(chan, data)
        end,
        stdout_buffered = true,
        stderr_buffered = true,
    })
end

function M.setup(config)
    config = config or {}

    -- Java Format command
    vim.api.nvim_create_user_command('JavaFormat', function()
        -- Check if google-java-format is available
        if vim.fn.executable('google-java-format') == 1 then
            vim.cmd('silent !google-java-format -i %')
            vim.notify("Formatted with google-java-format", vim.log.levels.INFO)
        else
            -- Try build tool specific formatting
            if vim.fn.filereadable('build.gradle') == 1 or vim.fn.filereadable('build.gradle.kts') == 1 then
                run_in_term({ "sh", "-c", "./gradlew spotlessApply" }, "[Gradle Format]")
            elseif vim.fn.filereadable('pom.xml') == 1 then
                run_in_term({ "sh", "-c", "mvn spotless:apply" }, "[Maven Format]")
            else
                vim.notify("No formatter found. Install google-java-format or configure spotless plugin.", vim.log.levels.WARN)
            end
        end
    end, {})

    -- Maven commands
    vim.api.nvim_create_user_command('MavenBuild', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mvn clean install %s", args) },
            "[Maven Build]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('MavenTest', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mvn test %s", args) },
            "[Maven Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('MavenRun', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mvn exec:java %s", args) },
            "[Maven Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('MavenClean', function(opts)
        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("mvn clean %s", args) },
            "[Maven Clean]"
        )
    end, { nargs = "*" })

    -- Gradle commands
    vim.api.nvim_create_user_command('GradleBuild', function(opts)
        local gradle_wrapper = './gradlew'
        if vim.fn.executable(gradle_wrapper) == 0 then
            gradle_wrapper = 'gradle'
        end

        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("%s build %s", gradle_wrapper, args) },
            "[Gradle Build]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('GradleTest', function(opts)
        local gradle_wrapper = './gradlew'
        if vim.fn.executable(gradle_wrapper) == 0 then
            gradle_wrapper = 'gradle'
        end

        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("%s test %s", gradle_wrapper, args) },
            "[Gradle Test]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('GradleRun', function(opts)
        local gradle_wrapper = './gradlew'
        if vim.fn.executable(gradle_wrapper) == 0 then
            gradle_wrapper = 'gradle'
        end

        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("%s run %s", gradle_wrapper, args) },
            "[Gradle Run]"
        )
    end, { nargs = "*" })

    vim.api.nvim_create_user_command('GradleClean', function(opts)
        local gradle_wrapper = './gradlew'
        if vim.fn.executable(gradle_wrapper) == 0 then
            gradle_wrapper = 'gradle'
        end

        local args = opts.args or ""
        run_in_term(
            { "sh", "-c", string.format("%s clean %s", gradle_wrapper, args) },
            "[Gradle Clean]"
        )
    end, { nargs = "*" })

    -- Run Tests command
    vim.api.nvim_create_user_command('RunTests', function()
        if vim.fn.filereadable('build.gradle') == 1 or vim.fn.filereadable('build.gradle.kts') == 1 then
            local gradle_wrapper = './gradlew'
            if vim.fn.executable(gradle_wrapper) == 0 then
                gradle_wrapper = 'gradle'
            end
            run_in_term({ "sh", "-c", gradle_wrapper .. " test" }, "[Gradle Test]")
        elseif vim.fn.filereadable('pom.xml') == 1 then
            run_in_term({ "sh", "-c", "mvn test" }, "[Maven Test]")
        else
            vim.notify("No build file found", vim.log.levels.WARN)
        end
    end, {})

    -- Java Run command
    vim.api.nvim_create_user_command('JavaRun', function(opts)
        local main_class = vim.fn.input('Main class: ', '', 'file')
        if main_class ~= '' then
            local args = opts.args or ""
            run_in_term(
                { "sh", "-c", string.format("java %s %s", main_class, args) },
                "[Java Run]"
            )
        end
    end, { nargs = "*" })

    -- JFR commands
    vim.api.nvim_create_user_command('StartJFR', function()
        vim.notify("JFR profiling requires JVM flags. Add -XX:+FlightRecorder -XX:StartFlightRecording=...", vim.log.levels.INFO)
    end, {})

    vim.api.nvim_create_user_command('StopJFR', function()
        vim.notify("JFR profiling requires JVM flags. Add -XX:+FlightRecorder -XX:StartFlightRecording=...", vim.log.levels.INFO)
    end, {})

    -- Async Profiler command
    vim.api.nvim_create_user_command('StartAsyncProfiler', function()
        vim.notify("Install async-profiler and use: java -agentpath:/path/to/libasyncProfiler.so=start,...", vim.log.levels.INFO)
    end, {})

    -- Package analysis
    vim.api.nvim_create_user_command('JavaPackageAnalyze', function()
        if vim.fn.executable('jdeps') == 1 then
            run_in_term({ "sh", "-c", "jdeps " .. vim.fn.expand('%') }, "[Java Dependencies]")
        else
            vim.notify("jdeps not found. Install JDK with jdeps command.", vim.log.levels.WARN)
        end
    end, {})

    -- Coverage command
    vim.api.nvim_create_user_command('JavaCoverage', function()
        vim.notify("Use JaCoCo Maven/Gradle plugin for coverage reports", vim.log.levels.INFO)
    end, {})

    -- Security analysis commands
    vim.api.nvim_create_user_command('JavaSecurityCheck', function()
        if vim.fn.filereadable('pom.xml') == 1 then
            run_in_term({ "sh", "-c", "mvn dependency-check:check" }, "[OWASP Dependency Check]")
        elseif vim.fn.filereadable('build.gradle') == 1 or vim.fn.filereadable('build.gradle.kts') == 1 then
            vim.notify("Configure OWASP Dependency-Check Gradle plugin for security scanning", vim.log.levels.INFO)
        else
            vim.notify("No build file found for security check", vim.log.levels.WARN)
        end
    end, {})

    -- Memory analysis
    vim.api.nvim_create_user_command('JavaHeapDump', function()
        vim.notify("Use -XX:+HeapDumpOnOutOfMemoryError JVM flag or jcmd <pid> GC.run_finalization", vim.log.levels.INFO)
    end, {})

    -- Neotest integration
    local neotest_status_ok, neotest = pcall(require, "neotest")
    if neotest_status_ok then
        neotest.setup({
            adapters = {
                require("neotest-java")({
                    -- Configuration options for neotest-java
                }),
            },
        })
    end

    -- Integrate with conform.nvim for formatting
    local conform_status, conform = pcall(require, "conform")
    if conform_status then
        -- We don't add to formatters_by_ft here because we want to keep it optional
        -- User can add this to their conform setup:
        -- formatters_by_ft = {
        --   java = { "google_java_format" },
        -- }
    end
end

return M