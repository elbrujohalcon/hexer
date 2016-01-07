-module(hexer_deps_SUITE).

-include_lib("inaka_mixer/include/mixer.hrl").
-mixin([{ hexer_test_utils
        , [ init_per_suite/1
          , end_per_suite/1
          ]
        }
       ]).

-export([ all/0
        ]).

-export([ resolve_basic/1
        , resolve_empty/1
        , resolve_multiple_lines/1
        ]).

-spec all() -> [atom()].
all() -> hexer_test_utils:all(?MODULE).

-spec resolve_basic(hexer_test_utils:config()) -> {comment, string()}.
resolve_basic(_Config) ->

  ct:comment("Simple Makefile works"),
  create_makefile(
    "DEPS = dep1 dep2 dep3\n"
    "\n"
    "dep_dep1 = hex 0.1.2\n"
    "dep_dep2 = git https://github.com/user/dep2 b00b1e5\n"
    ),

  [{dep1, "0.1.2"}] = hexer_deps:resolve("."),

  ct:comment("Shell/Test Deps should be ignored"),
  create_makefile(
    "DEPS = dep1 dep2 dep3\n"
    "TEST_DEPS = dep4 dep5\n"
    "SHELL_DEPS = dep6 dep7\n"
    "\n"
    "dep_dep1 = hex 0.1.2\n"
    "dep_dep2 = git https://github.com/user/dep2 b00b1e5\n"
    "dep_dep4 = hex 3.4.5\n"
    "dep_dep5 = git https://github.com/user/dep5 e666999a\n"
    "dep_dep6 = hex 6.7.8\n"
    ),

  [{dep1, "0.1.2"}] = hexer_deps:resolve("."),

  {comment, ""}.

-spec resolve_empty(hexer_test_utils:config()) -> {comment, string()}.
resolve_empty(_Config) ->

  ct:comment("Empty Makefile should produce no deps"),
  create_makefile(""),
  [] = hexer_deps:resolve("."),

  ct:comment("No hex deps produce no deps"),
  create_makefile(
    "DEPS = dep1 dep2 dep3\n"
    "\n"
    "dep_dep1 = cp /a/path\n"
    "dep_dep2 = git https://github.com/user/dep2 b00b1e5\n"
    ),

  [] = hexer_deps:resolve("."),

  ct:comment("Shell/Test Deps should be ignored"),
  create_makefile(
    "DEPS = dep1 dep2 dep3\n"
    "TEST_DEPS = dep4 dep5\n"
    "SHELL_DEPS = dep6 dep7\n"
    "\n"
    "dep_dep2 = git https://github.com/user/dep2 b00b1e5\n"
    "dep_dep4 = hex 3.4.5\n"
    "dep_dep5 = git https://github.com/user/dep5 e666999a\n"
    "dep_dep6 = hex 6.7.8\n"
    ),

  [] = hexer_deps:resolve("."),

  {comment, ""}.

-spec resolve_multiple_lines(hexer_test_utils:config()) -> {comment, string()}.
resolve_multiple_lines(_Config) ->

  ct:comment("Simple Makefile works"),
  create_makefile(
    "DEPS = dep1 dep2\n"
    "DEPS += dep3\n"
    "\n"
    "dep_dep1 = hex 0.1.2\n"
    "dep_dep2 = git https://github.com/user/dep2 b00b1e5\n"
    "dep_dep3 = hex 3.4.5\n"
    ),

  [{dep1, "0.1.2"}, {dep3, "3.4.5"}] = hexer_deps:resolve("."),

  ct:comment("Shell/Test Deps should be ignored"),
  create_makefile(
    "DEPS = dep1 dep2\n"
    "TEST_DEPS = dep4 dep5\n"
    "DEPS += dep3\n"
    "SHELL_DEPS = dep6 dep7\n"
    "\n"
    "dep_dep1 = hex 6.7.8\n"
    "dep_dep2 = git https://github.com/user/dep2 b00b1e5\n"
    "dep_dep3 = hex 9.0.1\n"
    "dep_dep4 = hex 2.3.4\n"
    "dep_dep5 = git https://github.com/user/dep5 e666999a\n"
    "dep_dep6 = hex 5.6.7\n"
    ),

  [{dep1, "6.7.8"}, {dep3, "9.0.1"}] = hexer_deps:resolve("."),

  {comment, ""}.

create_makefile(Contents) ->
  ok = file:write_file("Makefile", ["include ../../erlang.mk\n", Contents]).
