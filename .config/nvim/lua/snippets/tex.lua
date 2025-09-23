local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require('luasnip.extras').lambda
local rep = require('luasnip.extras').rep
local p = require('luasnip.extras').partial
local m = require('luasnip.extras').match
local n = require('luasnip.extras').nonempty
local dl = require('luasnip.extras').dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local types = require 'luasnip.util.types'
local conds = require 'luasnip.extras.expand_conditions'
local postfix = require('luasnip.extras.postfix').postfix
local parse = require('luasnip.util.parser').parse_snippet

-- Helper functions
local function create_table(rows, cols)
  local offset = cols + 1
  local table_lines = {}

  -- Begin tabular
  local col_spec = {}
  for i = 1, cols do
    table.insert(col_spec, '$' .. i)
  end
  table.insert(table_lines, '\\begin{tabular}{|' .. table.concat(col_spec, '|') .. '|}')

  -- Table rows
  for i = 1, rows do
    local row_cells = {}
    for j = 1, cols do
      table.insert(row_cells, '$' .. (i - 1) * cols + j + offset)
    end
    table.insert(table_lines, '\t' .. table.concat(row_cells, ' & ') .. ' \\\\')
  end

  -- End tabular
  table.insert(table_lines, '\\end{tabular}')

  return table_lines
end

local build_snippet = function(trig, node, match, priority, name)
  return s({
    name = name and name(match) or match,
    trig = trig(match),
    priority = priority,
  }, vim.deepcopy(node))
end

local build_with_priority = function(trig, node, priority, name)
  return function(match)
    return build_snippet(trig, node, match, priority, name)
  end
end

local postfix_trig = function(match)
  return string.format('(%s)', match)
end

local postfix_node = f(function(_, snip)
  for key, value in pairs(snip) do
    print(key, value, snip.env.MATCH)
  end
  return string.format('\\%s ', snip.env.MATCH)
end, {})

local greek_postfix_completions = function()
  local re =
    '[aA]lpha|[bB]eta|[cC]hi|[dD]elta|[eE]psilon|[gG]amma|[iI]ota|[kK]appa|[lL]ambda|[mM]u|[nN]u|[oO]mega|[pP]hi|[pP]i|[pP]si|[rR]ho|[sS]igma|[tT]au|[tT]heta|[zZ]eta|[eE]ta'

  local build = build_with_priority(postfix_trig, postfix_node, 200)
  return vim.tbl_map(build, vim.split(re, '|'))
end

local function basename()
  return vim.fn.expand '%:t:r'
end

local s = {
  -- GLOBAL SNIPPETS
  s('pkg', {
    t '\\usepackage{',
    i(1),
    t '}',
  }),

  -- ENVIRONMENT SNIPPETS
  s('dd', {
    t '\\dd{',
    i(1),
    t '}',
  }),

  s('beg', {
    t '\\begin{',
    i(1),
    t '}',
    t { '', '' },
    i(0),
    t { '', '\\end{' },
    rep(1),
    t '}',
  }),

  s('·', {
    t '\\cdot ',
  }),

  s('lemma', {
    t { '\\begin{lemma}', '\t' },
    i(0),
    t { '', '\\end{lemma}' },
  }),

  s('prop', {
    t '\\begin{prop}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{prop}' },
  }),

  s('thrm', {
    t '\\begin{teorema}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{teorema}' },
  }),

  s('post', {
    t '\\begin{postulate}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{postulate}' },
  }),

  s('prf', {
    t { '\\begin{proof}[Demostración]', '\t' },
    i(0),
    t { '', '\\end{proof}' },
  }),

  s('itmize', {
    t { '\\begin{itemize}', '\t' },
    i(0),
    t { '', '\\end{itemize}' },
  }),

  s('def', {
    t '\\begin{definition}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{definition}' },
  }),

  s('nte', {
    t '\\begin{note}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{note}' },
  }),

  s('prob', {
    t '\\begin{problem}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{problem}' },
  }),

  s('corl', {
    t '\\begin{corollary}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{corollary}' },
  }),

  s('example', {
    t '\\begin{example}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{example}' },
  }),

  s('notion', {
    t '\\begin{notation}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{notation}' },
  }),

  s('conc', {
    t '\\begin{conclusion}[',
    i(1),
    t { ']', '\t' },
    i(0),
    t { '', '\\end{conclusion}' },
  }),

  s('fig', {
    t '\\begin{figure}[',
    i(1, 'htpb'),
    t { ']', '\t\\centering', '\t' },
    i(2, '\\includegraphics[width=0.8\\textwidth]{'),
    i(3),
    t '}',
    t { '', '\t\\caption{' },
    i(4),
    t '}',
    t { '', '\t\\label{fig:' },
    i(5),
    t '}',
    t { '', '\\end{figure}' },
  }),

  s('abs', {
    t { '\\begin{abstract}', '\t' },
    i(0),
    t { '', '.\\end{abstract}' },
  }),

  s('tab', {
    t '\\begin{',
    i(1, 'tabular'),
    t '}{',
    i(2, 'c'),
    t '}',
    t { '', '' },
    i(0),
    t { '', '\\end{' },
    rep(1),
    t '}',
  }),

  s('table', {
    t '\\begin{table}[',
    i(1, 'htpb'),
    t { ']', '\t\\centering', '\t\\caption{' },
    i(2, 'caption'),
    t '}',
    t { '', '\t\\label{tab:' },
    i(3, 'label'),
    t '}',
    t { '', '', '\t\\begin{tabular}{' },
    i(4, 'c'),
    t '}',
    t { '', '\t\t' },
    i(0),
    t { '', '\t\\end{tabular}', '\\end{table}' },
  }),

  s('writing', {
    t { '\\documentclass{article}', '\\author{Alejandro Zubiri}', '\\title{' },
    f(function()
      return basename()
    end),
    t '}',
    t { '', '', '\\begin{document}', '\\maketitle', '\\tableofcontents', '\\pagebreak', '', '' },
    i(0),
    t { '', '\\end{document}' },
  }),

  s('writingsubfile', {
    t '\\documentclass{../',
    i(1),
    t { '}', '', '\\begin{document}' },
    i(0),
    t { '', '\\end{document}' },
  }),

  s('writing_math', {
    t { '\\documentclass{article}', '\\author{Alejandro Zubiri}', '\\title{' },
    f(function()
      return basename()
    end),
    t '}',
    t {
      '',
      '',
      '\\renewcommand*\\contentsname{Índice}',
      '',
      '\\usepackage[margin=1.1in]{geometry}',
      '\\usepackage{amsmath, physics, amsthm, amsfonts, mdframed, subfiles, tikz}',
      '\\usepackage[a]{esvect}',
      '',
      '\\newmdtheoremenv{teorema}{Teorema}',
      '\\newmdtheoremenv{defin}{Definición}',
      '',
      '\\newcommand{\\R}{\\mathbb{R}}',
      '',
      '\\begin{document}',
      '\\maketitle',
      '\\tableofcontents',
      '\\pagebreak',
    },
    i(0),
    t { '', '\\end{document}' },
  }),

  s('sec', {
    t '\\section{',
    i(0),
    t '}',
  }),

  s('ssec', {
    t '\\subsection{',
    i(0),
    t '}',
  }),

  -- GREEK LETTERS (lowercase)
  s({
    trig = '@vp',
    wordTrig = false,
  }, { t '\\varphi' }),
  s({ trig = '@a', priority = 1500 }, { t '\\alpha' }),
  s({ trig = '@b', priority = 1500 }, { t '\\beta' }),
  s({ trig = '@g', priority = 1500 }, { t '\\gamma' }),
  s({ trig = '@d', priority = 1500 }, { t '\\delta' }),
  s({ trig = '@e', priority = 1500 }, { t '\\epsilon' }),
  s({ trig = '@z', priority = 1500 }, { t '\\zeta' }),
  s({ trig = '@h', priority = 1500 }, { t '\\eta' }),
  s({ trig = '@t', priority = 1500 }, { t '\\theta' }),
  s({ trig = '@i', priority = 1500 }, { t '\\iota' }),
  s({ trig = '@k', priority = 1500 }, { t '\\kappa' }),
  s({ trig = '@l', priority = 1500 }, { t '\\lambda' }),
  s({ trig = '@m', priority = 1500 }, { t '\\mu' }),
  s({ trig = '@n', priority = 1500 }, { t '\\nu' }),
  s({ trig = '@xi', priority = 1500 }, { t '\\xi' }),
  s({ trig = '@o', priority = 1500 }, { t '\\omicron' }),
  s({ trig = '@p', priority = 1500 }, { t '\\pi' }),
  s({ trig = '@r', priority = 1500 }, { t '\\rho' }),
  s({ trig = '@s', priority = 1500 }, { t '\\sigma' }),
  s({ trig = '@u', priority = 1500 }, { t '\\upsilon' }),
  s({ trig = '@phi', priority = 1500 }, { t '\\phi' }),
  s({ trig = '@chi', priority = 1500 }, { t '\\chi' }),
  s({ trig = '@psi', priority = 1500 }, { t '\\psi' }),
  s({ trig = '@w', priority = 1500 }, { t '\\omega' }),
  -- GREEK LETTERS (uppercase)
  s({ trig = '@A', priority = 1500 }, { t '\\Alpha' }),
  s({ trig = '@B', priority = 1500 }, { t '\\Beta' }),
  s({ trig = '@G', priority = 1500 }, { t '\\Gamma' }),
  s({ trig = '@D', priority = 1500 }, { t '\\Delta' }),
  s({ trig = '@E', priority = 1500 }, { t '\\Epsilon' }),
  s({ trig = '@Z', priority = 1500 }, { t '\\Zeta' }),
  s({ trig = '@H', priority = 1500 }, { t '\\Eta' }),
  s({ trig = '@T', priority = 1500 }, { t '\\Theta' }),
  s({ trig = '@I', priority = 1500 }, { t '\\Iota' }),
  s({ trig = '@K', priority = 1500 }, { t '\\Kappa' }),
  s({ trig = '@L', priority = 1500 }, { t '\\Lambda' }),
  s({ trig = '@M', priority = 1500 }, { t '\\Mu' }),
  s({ trig = '@N', priority = 1500 }, { t '\\Nu' }),
  s({ trig = '@Xi', priority = 1500 }, { t '\\Xi' }),
  s({ trig = '@O', priority = 1500 }, { t '\\Omicron' }),
  s({ trig = '@P', priority = 1500 }, { t '\\Pi' }),
  s({ trig = '@R', priority = 1500 }, { t '\\Rho' }),
  s({ trig = '@S', priority = 1500 }, { t '\\Sigma' }),
  s({ trig = '@U', priority = 1500 }, { t '\\Upsilon' }),
  s({ trig = '@Phi', priority = 1500 }, { t '\\Phi' }),
  s({ trig = '@Chi', priority = 1500 }, { t '\\Chi' }),
  s({ trig = '@Psi', priority = 1500 }, { t '\\Psi' }),
  s({ trig = '@W', priority = 1500 }, { t '\\Omega' }),
  s({ trig = '@ve', priority = 1500 }, { t '\\varepsilon' }),
  -- MATH SNIPPETS
  s('vb', {
    t '\\vb{',
    i(1),
    t '}',
  }),

  s('mcal', {
    t '\\mathcal{',
    i(1),
    t '}',
  }),

  s('mbf', {
    t '\\mathbf{',
    i(1),
    t '}',
  }),

  s('tbf', {
    t '\\textbf{',
    i(1),
    t '}',
  }),

  s('nabl', { t '\\nabla' }),

  s('vv', {
    t '\\vv{',
    i(1),
    t '}',
  }),

  s('>>', { t '\\mapsto' }),

  s('RR', { t '\\mathbb{R}' }),

  s('set', {
    t '\\{ ',
    i(0),
    t ' \\}',
  }),

  s('verb', {
    t '\\verb|',
    i(0),
    t '|',
  }),

  s('verbat', {
    t { '\\begin{verbatim}', '' },
    i(0),
    t { '', '\\end{verbatim}' },
  }),

  s('...', { t '\\dots ' }),

  s('vec', {
    t '\\vec{',
    i(0),
    t '}',
  }),

  s('forall', { t '\\forall' }),

  s('mbb', {
    t '\\mathbb{',
    i(0),
    t '}',
  }),

  s('exists', { t '\\exists' }),

  s('inn', { t '\\in' }),

  s('!=', { t '\\neq' }),

  s('<=', { t '\\leq' }),

  s('>=', { t '\\geq' }),

  s('tp', {
    t '^{',
    i(0),
    t '}',
  }),

  s('_', {
    t '_{',
    i(0),
    t '}',
  }),

  s('eqq', {
    t { '\\begin{equation}', '\t\\begin{split}', '\t\t' },
    i(0),
    t { '', '\t\\end{split}', '\\end{equation}' },
  }),

  s('cc', { t '\\subset ' }),

  s('Nn', { t '\\cap ' }),

  s('UU', { t '\\cup ' }),

  s('uuu', {
    t '\\bigcup_{',
    i(1, 'i \\in '),
    i(2, 'I'),
    t '} ',
    i(0),
  }),

  s('nnn', {
    t '\\bigcap_{',
    i(1, 'i \\in '),
    i(2, 'I'),
    t '} ',
    i(0),
  }),

  s('HH', { t '\\mathbb{H}' }),

  s('DD', { t '\\mathbb{D}' }),

  s('mk', {
    t '$',
    i(1),
    t '$ ',
    i(0),
  }),

  s('dm', {
    t { '\\[', '\t' },
    i(1),
    t { '', '\\]' },
    i(0),
  }),

  s('frac', {
    t '\\frac{',
    i(1),
    t '}{',
    i(2),
    t '}',
    i(0),
  }),

  s('compl', { t '^{c}' }),

  s('ss', {
    t '^{',
    i(1),
    t '}',
    i(0),
  }),

  s('__', {
    t '_{',
    i(1),
    t '}',
    i(0),
  }),

  s('sqr', {
    t '\\sqrt{',
    i(1),
    t '}',
    i(0),
  }),

  s('sr', { t '^{2}' }),

  s('srto', {
    t '\\sqrt[',
    i(1),
    t ']{',
    i(2),
    t '}',
    i(0),
  }),

  s('ceil', {
    t '\\left\\lceil ',
    i(1),
    t ' \\right\\rceil ',
    i(0),
  }),

  s('floor', {
    t '\\left\\lfloor ',
    i(1),
    t ' \\right\\rfloor',
    i(0),
  }),

  s('pmat', {
    t '\\begin{pmatrix} ',
    i(1),
    t ' \\end{pmatrix} ',
    i(0),
  }),

  s('vmat', {
    t '\\begin{vmatrix} ',
    i(1),
    t ' \\end{vmatrix} ',
    i(0),
  }),

  s('bmat', {
    t '\\begin{bmatrix} ',
    i(1),
    t ' \\end{bmatrix} ',
    i(0),
  }),

  s('lrb', {
    t '\\left\\{ ',
    i(1),
    t ' \\right\\} ',
    i(0),
  }),

  s('lra', {
    t '\\left<',
    i(1),
    t ' \\right>',
    i(0),
  }),

  s('conj', {
    t '\\overline{',
    i(1),
    t '}',
    i(0),
  }),

  s('sum', {
    t '\\sum_{n=',
    i(1, '1'),
    t '}^{',
    i(2, '\\infty'),
    t '} ',
    i(3, 'a_n z^n'),
  }),

  s('taylor', {
    t '\\sum_{',
    i(1, 'k'),
    t '=',
    i(2, '0'),
    t '}^{',
    i(3, '\\infty'),
    t '} ',
    i(4, 'c_'),
    rep(1),
    t ' (x-a)^',
    rep(1),
    t ' ',
    i(0),
  }),

  s('lim', {
    t '\\lim_{',
    i(1, 'n'),
    t ' \\to ',
    i(2, '\\infty'),
    t '} ',
  }),

  s('limsup', {
    t '\\limsup_{',
    i(1, 'n'),
    t ' \\to ',
    i(2, '\\infty'),
    t '} ',
  }),

  s('prod', {
    t '\\prod_{',
    i(1, 'n='),
    i(2, '1'),
    t '}^{',
    i(3, '\\infty'),
    t '} ',
    i(4),
    t ' ',
    i(0),
  }),

  s('part', {
    t '\\frac{\\partial ',
    i(1, 'V'),
    t '}{\\partial ',
    i(2, 'x'),
    t '} ',
    i(0),
  }),

  s('ooo', { t '\\infty' }),

  s('rij', {
    t '(',
    i(1, 'x'),
    t '_',
    i(2, 'n'),
    t ')_{',
    i(3),
    t '\\in',
    i(4, '\\N'),
    t '}',
    i(0),
  }),

  s('imp', { t '\\implies' }),

  s('=<', { t '\\impliedby' }),

  s('iff', { t '\\iff' }),

  s('==', {
    t '&= ',
    i(1),
    t ' \\\\',
  }),

  s('nn', {
    t '\\node[',
    i(5),
    t '] (',
    i(1),
    i(2),
    t ') ',
    i(3, 'at ('),
    i(4, '0,0'),
    t ') {$',
    rep(1),
    t '$};',
    t { '', '' },
    i(0),
  }),

  s('lll', { t '\\ell' }),

  s('xx', { t '\\times ' }),

  s('<!', { t '\\triangleleft ' }),

  s('!>', { t '\\mapsto ' }),

  -- POSTFIX SNIPPETS
  s('bar', {
    t '\\bar{',
    i(1),
    t '}',
    i(0),
  }),

  -- PREAMBLE
  s('pac', {
    t '\\usepackage',
    c(1, {
      sn(nil, { t '[', i(1), t ']' }),
      t '',
    }),
    t '{',
    i(2),
    t '}',
    i(0),
  }),

  s('docls', {
    t '\\documentclass{',
    i(1),
    t '}',
    i(0),
  }),

  -- OTHER
  s('acl', {
    t '\\acl{',
    i(1, 'acronym'),
    t '}',
  }),

  s('ac', {
    t '\\ac{',
    i(1, 'acronym'),
    t '}',
  }),

  -- REGEX SNIPPETS (simplified versions)
  -- Note: LuaSnip regex patterns work differently than UltiSnips
  -- These are simplified versions that capture the main functionality

  -- Auto subscript for single digit
  s({ trig = '([A-Za-z])(%d)', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1] .. '_' .. snip.captures[2]
    end),
  }),

  -- Auto subscript for double digit
  s({ trig = '([A-Za-z])_(%d%d)', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1] .. '_{' .. snip.captures[2] .. '}'
    end),
  }),

  -- Inverse
  s({ trig = '([%w]+)invs', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1] .. '^{-1}'
    end),
  }),

  -- Math functions
  s({ trig = '(sin|cos|arccot|cot|csc|ln|log|exp|star|perp)', regTrig = true }, {
    f(function(_, snip)
      return '\\' .. snip.captures[1]
    end),
  }),

  -- Fraction with numbers
  s({ trig = '(%d+)/', regTrig = true }, {
    f(function(_, snip)
      return '\\frac{' .. snip.captures[1] .. '}{'
    end),
    i(1),
    t '}',
    i(0),
  }),

  -- Table generation (simplified)
  s({ trig = 'gentbl(%d+)x(%d+)', regTrig = true }, {
    f(function(_, snip)
      local rows = tonumber(snip.captures[1])
      local cols = tonumber(snip.captures[2])
      return table.concat(create_table(rows, cols), '\n')
    end),
  }),

  -- Bra-ket notation
  s({ trig = '<([^|]*)%|', regTrig = true }, {
    t '\\bra{',
    f(function(_, snip)
      return snip.captures[1]:gsub('q', '\\psi'):gsub('f', '\\phi')
    end),
    t '}',
  }),

  s({ trig = '%|([^>]*)>', regTrig = true }, {
    t '\\ket{',
    f(function(_, snip)
      return snip.captures[1]:gsub('q', '\\psi'):gsub('f', '\\phi')
    end),
    t '}',
  }),
}

vim.list_extend(s, greek_postfix_completions())

-- Greek letters
-- Deshabilitamos el mapping default
vim.keymap.set('i', '<C-g>', '<nop>')
vim.keymap.set('i', '<C-g>a', '\\alpha', { buffer = 0 })
vim.keymap.set('i', '<C-g>A', 'A', { buffer = 0 })
vim.keymap.set('i', '<C-g>b', '\\beta', { buffer = 0 })
vim.keymap.set('i', '<C-g>B', 'B', { buffer = 0 })
vim.keymap.set('i', '<C-g>c', '\\chi', { buffer = 0 })
vim.keymap.set('i', '<C-g>C', 'X', { buffer = 0 })
vim.keymap.set('i', '<C-g>d', '\\delta', { buffer = 0 })
vim.keymap.set('i', '<C-g>D', '\\Delta', { buffer = 0 })
vim.keymap.set('i', '<C-g>e', '\\epsilon', { buffer = 0 })
vim.keymap.set('i', '<C-g>E', 'E', { buffer = 0 })
vim.keymap.set('i', '<C-g>1', '\\eta', { buffer = 0 })
vim.keymap.set('i', '<C-g>!', 'E', { buffer = 0 })
vim.keymap.set('i', '<C-g>g', '\\gamma', { buffer = 0 })
vim.keymap.set('i', '<C-g>G', '\\Gamma', { buffer = 0 })
vim.keymap.set('i', '<C-g>i', '\\iota', { buffer = 0 })
vim.keymap.set('i', '<C-g>I', 'I', { buffer = 0 })
vim.keymap.set('i', '<C-g>k', '\\kappa', { buffer = 0 })
vim.keymap.set('i', '<C-g>K', 'K', { buffer = 0 })
vim.keymap.set('i', '<C-g>l', '\\lambda', { buffer = 0 })
vim.keymap.set('i', '<C-g>L', '\\Lambda', { buffer = 0 })
vim.keymap.set('i', '<C-g>m', '\\mu', { buffer = 0 })
vim.keymap.set('i', '<C-g>M', 'M', { buffer = 0 })
vim.keymap.set('i', '<C-g>n', '\\nu', { buffer = 0 })
vim.keymap.set('i', '<C-g>N', 'N', { buffer = 0 })
vim.keymap.set('i', '<C-g>o', '\\omega', { buffer = 0 })
vim.keymap.set('i', '<C-g>O', '\\Omega', { buffer = 0 })
vim.keymap.set('i', '<C-g>f', '\\phi', { buffer = 0 })
vim.keymap.set('i', '<C-g>F', '\\Phi', { buffer = 0 })
vim.keymap.set('i', '<C-g>p', '\\psi', { buffer = 0 })
vim.keymap.set('i', '<C-g>P', '\\Psi', { buffer = 0 })
vim.keymap.set('i', '<C-g>3', '\\pi', { buffer = 0 })
vim.keymap.set('i', '<C-g>#', '\\Pi', { buffer = 0 })
vim.keymap.set('i', '<C-g>r', '\\rho', { buffer = 0 })
vim.keymap.set('i', '<C-g>R', 'R', { buffer = 0 })
vim.keymap.set('i', '<C-g>s', '\\sigma', { buffer = 0 })
vim.keymap.set('i', '<C-g>S', '\\Sigma', { buffer = 0 })
vim.keymap.set('i', '<C-g>t', '\\tau', { buffer = 0 })
vim.keymap.set('i', '<C-g>T', 'T', { buffer = 0 })
vim.keymap.set('i', '<C-g>2', '\\theta', { buffer = 0 })
vim.keymap.set('i', '<C-g>@', '\\Theta', { buffer = 0 })
vim.keymap.set('i', '<C-g>u', '\\upsilon', { buffer = 0 })
vim.keymap.set('i', '<C-g>U', '\\Upsilon', { buffer = 0 })
vim.keymap.set('i', '<C-g>x', '\\xi', { buffer = 0 })
vim.keymap.set('i', '<C-g>X', '\\Xi', { buffer = 0 })
vim.keymap.set('i', '<C-g>z', '\\zeta', { buffer = 0 })
vim.keymap.set('i', '<C-g>Z', 'Z', { buffer = 0 })

ls.add_snippets('tex', s, { key = 'tex' })
