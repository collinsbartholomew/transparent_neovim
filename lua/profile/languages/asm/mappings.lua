---
-- Assembly keymaps
local wk = require("which-key")

local M = {}

function M.setup()
    -- Add assembly group to which-key
    wk.add({
        { "<leader>a",  group = "Assembly" },
        { "<leader>aa", group = "Assemble/Run" },
        { "<leader>ad", group = "Debug" },
        { "<leader>am", group = "Memory Analysis" },
        { "<leader>as", group = "Security Analysis" },
        { "<leader>at", group = "Templates" },
    })

    -- Assembly keymaps
    wk.add({
        -- Assemble and run
        { "<leader>aaa", "<cmd>OverseerRunCmd nasm -f elf64 % -o %<.o && ld %<.o -o %<<cr>", desc = "Assemble with NASM and link with LD" },
        { "<leader>aag", "<cmd>OverseerRunCmd as % -o %<.o && ld %<.o -o %<<cr>", desc = "Assemble with GAS and link with LD" },
        { "<leader>aar", "<cmd>OverseerRunCmd ./%<<cr>",                                    desc = "Run current assembly program" },
        { "<leader>aad", "<cmd>OverseerRunCmd gdb ./%<<cr>",                                desc = "Debug with GDB" },
        
        -- Debugging
        { "<leader>adb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",                   desc = "Toggle breakpoint" },
        { "<leader>adc", "<cmd>lua require'dap'.continue()<cr>",                            desc = "Continue execution" },
        { "<leader>adR", "<cmd>lua _G.assembly.setup_registers()<cr>",                      desc = "Show registers" },
        { "<leader>add", "<cmd>lua _G.assembly.disassemble()<cr>",                          desc = "Disassemble current file" },
        
        -- Memory analysis
        { "<leader>ama", "<cmd>OverseerRunCmd valgrind --leak-check=full ./%<<cr>",         desc = "Analyze memory with Valgrind" },
        { "<leader>amc", "<cmd>OverseerRunCmd valgrind --tool=cachegrind ./%<<cr>",         desc = "Cache profiling with Cachegrind" },
        { "<leader>amp", "<cmd>OverseerRunCmd perf record ./%< && perf report<cr>",         desc = "Performance profiling with Perf" },
        { "<leader>amm", "<cmd>OverseerRunCmd strace ./%<<cr>",                             desc = "Trace system calls" },
        
        -- Security analysis
        { "<leader>asc", "<cmd>OverseerRunCmd checksec --file=%<<cr>",                      desc = "Check binary security" },
        { "<leader>asr", "<cmd>OverseerRunCmd readelf -h %<<cr>",                           desc = "Read ELF header" },
        { "<leader>asn", "<cmd>OverseerRunCmd objdump -d %<<cr>",                           desc = "Disassemble with objdump" },
        { "<leader>asl", "<cmd>OverseerRunCmd ldd %<<cr>",                                  desc = "List dynamic dependencies" },
        { "<leader>ash", "<cmd>OverseerRunCmd hexdump -C %< | head -20<cr>",                desc = "Show hexdump" },
        
        -- Templates
        { "<leader>atn", "<cmd>lua require('profile.languages.asm.templates').nasm_template()<cr>", desc = "New NASM template" },
        { "<leader>atg", "<cmd>lua require('profile.languages.asm.templates').gas_template()<cr>",  desc = "New GAS template" },
    })
end

return M