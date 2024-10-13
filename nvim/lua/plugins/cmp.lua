return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    {
      'L3MON4D3/LuaSnip',
      config = function()
        local ls = require('luasnip')
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local d = ls.dynamic_node
        local sn = ls.snippet_node
        local extras = require('luasnip.extras')
        local l = extras.lambda
        -- local rep = extras.rep
        -- local dl = extras.dynamic_lambda
        local fmt = require('luasnip.extras.fmt').fmt
        local postfix = require('luasnip.extras.postfix').postfix

        ls.add_snippets('nix', {
          s(
            'pluginput',
            fmt('{a} = {{ url = "github:{b}"; flake = false; }};', {
              a = l(l._1:gsub('%.', '-'):gsub('^.+/', ''):gsub('%_', '-'):lower(), 1),
              b = i(1),
            })
          ),
          postfix({
            trig = '.plug',
            match_pattern = '[%w%.%_%-%/]+$',
          }, {
            d(1, function(_, parent)
              local match_no_author = parent.snippet.env.POSTFIX_MATCH:gsub('^.+/', '')
              local match_input_name = match_no_author:gsub('%.', '-'):gsub('%_', '-'):lower()
              vim.notify(vim.print(match_no_author))
              return sn(
                1,
                fmt('(mkNvimPlugin inputs.{} "{}")', {
                  t(match_input_name),
                  t(match_no_author),
                })
              )
            end),
          }),
        })
      end,
    },
    'saadparwaiz1/cmp_luasnip',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      completion = {
        completeopt = 'menu,menuone,preview,noselect',
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      }),
    })
  end,
}
