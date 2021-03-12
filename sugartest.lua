--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'sugartest';
addon.author    = 'atom0s';
addon.version   = '1.0';
addon.desc      = 'Tests the Ashita v4 sugar functional addon library.';
addon.link      = 'https://ashitaxi.com/';

--[[
* This is a simple addon demonstrating how to use the sugar functional library for Ashita. This is a library created
* to replace the old v3 extension libs for things like strings, tables, and so on. Including the common lib will automatically
* include the sugar library for you, similar to how v3 included the old extensions before. Different from v3 however, is that requiring
* common will now return a table of any sub-modules returns that common included.
*
* For example, common.lua will include sugar.lua, which itself has it's own table return. Thus, common will return a table containing sugars
* returned table. The keys in this returned table from common will be the name of the library it came from. (ie. sugar in this case.)
*
* -- Enable nil sugar..
* local c = require('common');
* c.sugar.enable_nil_sugar();
*
* For a list of credits regarding the sugar library, please see the sugar.lua lib file.
*
* The following tests are broken into parts based on the sugar sub-module they are for.
* Some tests may make use of other categories usages for ease of test writing.
--]]

-- Include the Ashita common libraries, which includes sugar..
local common = require('common');

--[[
*
* Tests     : Booleans
* Module    : boolean.lua
*
--]]

do
    -- Metatable: __index
    assert((false):isfalse() == true);
    assert((true):istrue() == true);
    assert((false):istrue() == false);
    assert((true):isfalse() == false);

    -- Metatable: __unm
    assert(-false == true);
    assert(-true == false);

    local f = false;
    local t = true;

    -- both
    assert(f:both(false) == false);
    assert(f:both(true) == false);
    assert(t:both(false) == false);
    assert(t:both(true) == true);

    -- either
    assert(f:either(false) == false);
    assert(f:either(true) == true);
    assert(t:either(false) == true);
    assert(t:either(true) == true);

    -- equals (is, match, matches, same)
    assert(f:equals(false) == true);
    assert(f:equals(true) == false);
    assert(t:equals(false) == false);
    assert(t:equals(true) == true);

    -- exists
    assert(f:exists() == true);
    assert(t:exists() == true);
    assert((not nil):exists() == true);

    -- isfalse
    assert(f:isfalse() == true);
    assert(t:isfalse() == false);

    -- istrue
    assert(f:istrue() == false);
    assert(t:istrue() == true);

    -- negate
    assert(f:negate() == true);
    assert(t:negate() == false);

    -- tonumber
    assert(f:tonumber() == 0);
    assert(t:tonumber() == 1);

    -- tostring
    assert(f:tostring() == 'false');
    assert(t:tostring() == 'true');
end

--[[
*
* Tests     : Functions
* Module    : function.lua
*
--]]

do
    -- Metatable: __add
    do
        local f = function (a, b) return a .. b; end
        assert((f+{'1'})('2') == '12');
    end

    -- Metatable: __concat
    do
        local f1 = function (a) return a + a; end
        local f2 = function (a, b) return a + b; end
        assert((f1 .. f2)(2, 2) == 8);
    end

    -- Metatable: __index
    do
        local f = function () return 11, 22, 33 end
        assert(f[1]() == 11);
        assert(f[2]() == 22);
        assert(f[3]() == 33);
        assert(f[4]() == nil);
    end

    -- Metatable: __mul
    do
        local x = 0;
        local f = function () x = x + 1; end
        local _ = (f * 4);
        assert(x == 4);
    end

    -- Metatable: __pow
    do
        local x = 0;
        local f = function () x = x + 1; end
        local _ = (f ^ 4);
        assert(x == 4);
    end

    -- Metatable: __sub
    do
        local f = function (a, b) return a .. b; end
        assert((f-{'1'})('2') == '21');
    end

    -- Metatable: __unm
    do
        local ff = function () return false; end
        local ft = function () return true; end

        assert(ff() == false);
        assert(ft() == true);
        assert(-ff() == true);
        assert(-ft() == false);
    end

    -- bench (benchmark, time)
    do
        -- We cannot guarantee a runtime here due to various system hardware configs and performances,
        -- so we just want to make sure it took at least the time we slept for.
        local function wait2() coroutine.sleep(2); end
        assert(wait2:bench() >= 2);
    end

    -- bind1 (bind, curry)
    -- bind2
    -- bindn
    do
        local function ret2(a, b) return a, b; end
        local r1, r2 = ret2:bind1(11)(22);
        assert(r1 == 11 and r2 == 22);

        r1, r2 = ret2:bind2(11)(22);
        assert(r1 == 22 and r2 == 11);

        local function ret4(a, b, c, d) return a, b, c, d; end
        local r3, r4 = 0, 0;
        r1, r2, r3, r4 = ret4:bindn(11)(22, 33, 44);
        assert(r1 == 11 and r2 == 22 and r3 == 33 and r4 == 44);
        r1, r2, r3, r4 = ret4:bindn(11, 22)(33, 44);
        assert(r1 == 11 and r2 == 22 and r3 == 33 and r4 == 44);
        r1, r2, r3, r4 = ret4:bindn(11, 22, 33)(44);
        assert(r1 == 11 and r2 == 22 and r3 == 33 and r4 == 44);
        r1, r2, r3, r4 = ret4:bindn(11, 22, 33, 44)();
        assert(r1 == 11 and r2 == 22 and r3 == 33 and r4 == 44);
    end

    -- call
    do
        local function f() return 123; end
        assert(f:call() == 123);
    end

    -- complement (negate)
    do
        local function f_false() return false; end
        local function f_true() return true; end

        assert(f_false:complement()() == true);
        assert(f_true:complement()() == false);
    end

    -- compose (pipe)
    do
        local function f_add1(a) return a + 1; end
        local function f_add2(a) return a + 2; end
        local function f_add3(a) return a + 3; end

        assert(f_add1:compose(f_add2, f_add3)(0) == 6);
        assert(f_add1:compose(f_add2, f_add3)(1) == 7);

        local function f_calc1(a) return a * 2; end
        local function f_calc2(a, b) return a + b; end
        local function f_calc3(a, b, c) return a + b, c; end

        -- Evaluates to: ((2 + 4) + 10) * 2
        assert(f_calc1:compose(f_calc2, f_calc3)(2, 4, 10) == 32);
    end

    -- cond (condition, execif)
    do
        local function cond_false() return false; end
        local function cond_true() return true; end
        local function f_call() return 1337; end

        assert(f_call:cond(cond_false)() == nil);
        assert(f_call:cond(cond_true)() == 1337);
    end

    -- constant (const)
    do
        -- Wrap a functions return to be constant..
        local function f_const() return 1337; end
        local f = f_const:constant()();

        -- Wrap anything else as constant..
        local n = common.sugar.constant(1234);
        local s = common.sugar.constant('derp');

        assert(f() == 1337);
        assert(n() == 1234);
        assert(s() == 'derp');
    end

    -- converge
    do
        local function f1_ret1() return 1; end
        local function f1_ret2() return 2; end
        local function f1_add2(a, b) return a + b; end

        assert(f1_add2:converge(f1_ret1, f1_ret2)() == 3);
    end

    -- dispatch
    do
        local calls = 0;
        local function f_call1() calls = calls + 1; end
        local function f_call2() calls = calls + 1; end
        local function f_call3() calls = calls + 1; return 1337; end
        local function f_call4() calls = calls + 1; end

        assert(f_call1:dispatch(f_call2, f_call3, f_call4)() == 1337 and calls == 3);
    end

    -- it (iter)
    do
        local val = 0;
        local function f_ret10() return 11, 22, 33, 44, 55, 66, 77, 88, 99, 100; end
        for x in f_ret10:it() do val = val + x; end

        assert(val == 595);
    end

    -- lcompose (lpipe)
    do
        local function f_add1(a) return a + 1; end
        local function f_add2(a) return a + 2; end
        local function f_add3(a) return a + 3; end

        assert(f_add1:lcompose(f_add2, f_add3)(0) == 6);
        assert(f_add1:lcompose(f_add2, f_add3)(1) == 7);

        local function f_calc1(a) return a * 2; end
        local function f_calc2(a, b) return a + b; end
        local function f_calc3(a, b, c) return a + b, c; end

        -- Evaluates to: ((2 + 4) + 10) * 2
        assert(f_calc3:lcompose(f_calc2, f_calc1)(2, 4, 10) == 32);
    end

    -- memoize
    do
        local calls = 0;
        local function f_add(a, b) calls = calls + 1; return a + b; end
        local function f_ret1(a) calls = calls + 1; return a; end
        local function f_ret0() calls = calls + 1; return 1337; end

        local f = f_add:memoize();
        assert(f(1, 2) == 3);
        assert(f(1, 2) == 3);
        assert(f(1, 2) == 3);
        assert(calls == 1);

        calls = 0;
        f = f_ret1:memoize();
        assert(f(11) == 11);
        assert(f(11) == 11);
        assert(f(11) == 11);
        assert(f(22) == 22);
        assert(calls == 2);

        calls = 0;
        f = f_ret0:memoize();
        assert(f() == 1337);
        assert(f() == 1337);
        assert(f() == 1337);
        assert(f() == 1337);
        assert(calls == 1);
    end

    -- partial (apply)
    do
        local function f_fmt4(a, b, c, d) return string.format('%s, %s, %s, %s', a, b, c, d); end
        local f = f_fmt4:partial('a', 'b');

        assert(f('c', 'd') == 'a, b, c, d');
    end

    -- partialend (applyend)
    do
        local function f_fmt4(a, b, c, d) return string.format('%s, %s, %s, %s', a, b, c, d); end
        local f = f_fmt4:partialend('a', 'b');

        assert(f('c', 'd') == 'c, d, a, b');
    end

    -- partialskip (skip)
    do
        local function test(a, b, c, d) return a, b, c, d; end
        local a, b, c, d = test:skip(2, 11, 22)('a', 'b', 'c', 'd');
        assert(a == 11);
        assert(b == 22);
        assert(c == 'c');
        assert(d == 'd');
    end

    -- prepare
    do
        local function f_prep(a, b, c, d) return a + b + c + d; end
        local f = f_prep:prepare(1, 2, 3, 4);

        assert(f() == 10);
    end

    -- rearg (args)
    do
        local function f_fmt4(a, b, c, d) return string.format('%s %s %s %s', a, b, c, d); end
        local f = f_fmt4:rearg(2, 1, 4, 3);

        assert(f('atom0s,', 'Hello', 'are you?', 'how') == 'Hello atom0s, how are you?');
    end

    -- select
    do
        local function f_ret4() return 11, 22, 33, 44; end
        local f1 = f_ret4:select(1);
        local f2 = f_ret4:select(2);
        local f3 = f_ret4:select(3);
        local f4 = f_ret4:select(4);

        assert(f1() == 11);
        assert(f2() == 22);
        assert(f3() == 33);
        assert(f4() == 44);

        -- This is also exposed via metatable function indexing for returns..
        assert(f_ret4[1]() == 11);
        assert(f_ret4[2]() == 22);
        assert(f_ret4[3]() == 33);
        assert(f_ret4[4]() == 44);
    end

    -- single (onetime, static)
    do
        local calls = 0;
        local function f_add(a, b) calls = calls + 1; return a + b; end
        local f = f_add:single();

        assert(f(2, 4) == 6);
        assert(f(2, 4) == 6);
        assert(f(2, 4) == 6);
        assert(calls == 1);
    end

    -- times
    do
        local calls = 0;
        local function f_call() calls = calls + 1; return calls; end

        local ret = f_call:times(4);
        assert(#ret == 4);
        assert(calls == 4);
    end

    -- tostring (str, tostr)
    do
        local function f_func() end
        assert(f_func:tostring():startswith('function:') == true);
    end

    -- type
    do
        local function f_func() end
        assert(f_func:type() == 'function');
    end

    -- wrap
    do
        local function f_wrapped() return 1337; end
        local function f_wrapper(f, b) return f() + b; end
        local f = f_wrapped:wrap(f_wrapper);

        assert(f(1) == 1338);
        assert(f(2) == 1339);
        assert(f(3) == 1340);
    end

    ----------------------------------------------------------------------------------------------------
    --
    -- Functional Helpers
    --
    ----------------------------------------------------------------------------------------------------

    -- all (both)
    do
        local function f_func1() return true; end
        local function f_func2() return true; end
        local function f_func3() return true; end
        local function f_func4() return false; end

        assert(f_func1:all(f_func2, f_func3)() == true);
        assert(f_func1:all(f_func2, f_func3, f_func4)() == false);
    end

    -- any (either)
    do
        local function f_func1() return true; end
        local function f_func2() return true; end
        local function f_func3() return true; end
        local function f_func4() return false; end

        assert(f_func1:any(f_func2, f_func3)() == true);
        assert(f_func1:any(f_func2, f_func3, f_func4)() == true);
    end

    -- count (counter)
    do
        local count = 0;
        local f = common.sugar.count(10);
        for x = 1, 12 do
            if (f()) then
                count = count + 1;
            end
        end
        assert(count == 10);
    end

    -- equals (eq)
    do
        local f1 = common.sugar.equals(1337);
        local f2 = function () return 1337; end
        local f3 = function () return 1338; end

        assert(f1(f2()) == true);
        assert(f1(f3()) == false);
    end

    -- none (neither)
    do
        local function f_func1() return true; end
        local function f_func2() return true; end
        local function f_func3() return true; end
        local function f_func4() return false; end

        assert(f_func1:none(f_func2, f_func3)() == false);
        assert(f_func1:none(f_func2, f_func3, f_func4)() == false);
        assert(f_func4:none(f_func4, f_func4, f_func4)() == true);
    end

    -- notequals (neq)
    do
        local f1 = common.sugar.notequals(1337);
        local f2 = function () return 1337; end
        local f3 = function () return 1338; end

        assert(f1(f2()) == false);
        assert(f1(f3()) == true);
    end

    ----------------------------------------------------------------------------------------------------
    --
    -- Functional Helpers (Coroutine Forwards via Ashita Tasks)
    --
    ----------------------------------------------------------------------------------------------------

    -- loop
    do
        -- Loop with a number condition..
        local x1 = 0;
        local cond1 = 5;
        local cb1 = function () assert(x1 == cond1); end
        local f1 = function () x1 = x1 + 1; end

        f1:loop(0.2, cond1, cb1);

        -- Loop with a function condition..
        local x2 = 0;
        local cond2 = function () return x2 < 10; end
        local cb2 = function () assert(x2 == 10); end
        local f2 = function () x2 = x2 + 1; end

        f2:loop(0.2, cond2, cb2);
    end

    -- loopf
    do
        -- Loop with a number condition..
        local x1 = 0;
        local cond1 = 5;
        local cb1 = function () assert(x1 == cond1); end
        local f1 = function () x1 = x1 + 1; end

        f1:loopf(5, cond1, cb1);

        -- Loop with a function condition..
        local x2 = 0;
        local cond2 = function () return x2 < 10; end
        local cb2 = function () assert(x2 == 10); end
        local f2 = function () x2 = x2 + 1; end

        f2:loopf(5, cond2, cb2);
    end

    -- once
    -- oncef
    -- repeating
    -- repeatingf
    do
        -- Because these are just forwards to Ashita's task system, there is no real means to test that these
        -- methods have completed properly. We will not be testing them because of this, but will call them.

        local f = function (str) print(string.format('\30\81[\30\06TestSugar\30\81] \30\106Called from: %s\30\01', str)); end

        f:once(1, 'once');
        f:oncef(1, 'oncef');
        f:repeating(1, 2, 1, 'repeating');
        f:repeatingf(1, 2, 1, 'repeatingf');
    end
end

--[[
*
* Tests     : Math
* Module    : math.lua
*
--]]

do
    -- Metatable: __index
    assert((0):add(1) == 1);

    -- approach
    assert((100):approach(0, 1) == 99);
    assert((100):approach(0, 5) == 95);
    assert((100):approach(0, 1.5) == 98.5);
    assert((100):approach(0, 5.5) == 94.5);
    assert((100):approach(200, 1) == 101);
    assert((100):approach(200, 5) == 105);

    -- base
    assert((1337):base(2) == '10100111001');
    assert((1337):base(8) == '2471');
    assert((1337):base(10) == '1337');
    assert((1337):base(16) == '539');

    -- binary
    assert((1337):binary() == '10100111001');

    -- char
    assert((65):char() == 'A');

    -- clamp
    assert((1337):clamp(0, 1400) == 1337);
    assert((1337):clamp(0, 1300) == 1300);
    assert((1337):clamp(1500, 2500) == 1500);

    -- degree
    assert((1):degree():round() == 57); -- 57.2958
    assert((1):deg():round() == 57); -- 57.2958

    -- degree_tau (deg_tau, degtau)
    assert((1):degree_tau():round() == 57); -- 57.2958

    -- hex
    assert((1337):hex() == '539');

    -- octal
    assert((1337):octal() == '2471');

    -- isinf
    assert((1):isinf() == false);
    assert((math.huge):isinf() == true);
    assert((-math.huge):isinf() == true);
    assert((2^9999):isinf() == true);
    assert(math.huge:isinf() == true);

    -- isnan
    assert((1):isnan() == false);
    assert((math.huge):isnan() == false);
    assert((0 / 0):isnan() == true);

    -- radian
    assert((100):radian():round() == 2); -- 1.7453292519943
    assert((100):rad():round() == 2);    -- 1.7453292519943

    -- radian_tau (rad_tau, radtau)
    assert((100):radian_tau():round() == 2); -- 1.7453292519943

    -- round
    assert((1):round() == 1);
    assert((1.2):round() == 1);
    assert((1.4):round() == 1);
    assert((1.5):round() == 2);
    assert((1.8):round() == 2);

    assert((1):round(2) == 1);
    assert((1.2222345):round(2) == 1.22);
    assert((1.4821334):round(2) == 1.48);
    assert((1.5412415):round(2) == 1.54);
    assert((1.8485631):round(2) == 1.85);

    -- sign
    assert((-1):sign() == -1);
    assert((0):sign() == 0);
    assert((1):sign() == 1);

    -- tostring (tostr, str, string)
    assert((1337):tostring() == '1337');
    assert((1337.1337):tostring() == '1337.1337');

    -- truncate
    assert((1):truncate() == 1);
    assert((1.2):truncate() == 1);
    assert((1.4):truncate() == 1);
    assert((1.5):truncate() == 1);
    assert((1.8):truncate() == 1);

    assert((1):truncate(2) == 1);
    assert((1.2222345):truncate(1) == 1.2);
    assert((1.4821334):truncate(1) == 1.4);
    assert((1.5412415):truncate(1) == 1.5);
    assert((1.8485631):truncate(1) == 1.8);

    -- within
    assert((5):within(1, 10) == true);
    assert((5):within(4, 6) == true);
    assert((5):within(5, 5) == true);
    assert((5):within(6, 10) == false);

    ----------------------------------------------------------------------------------------------------
    --
    -- Math Functions (Operators)
    --
    ----------------------------------------------------------------------------------------------------

    -- add
    assert((20):add(1) == 21);
    assert((30):add(2) == 32);
    assert((40):add(3) == 43);

    -- div (divide)
    assert((20):div(1) == 20);
    assert((30):div(2) == 15);
    assert((40):div(4) == 10);

    -- eq (equals)
    assert((10):eq(10) == true);
    assert((20):eq(20) == true);
    assert((30):eq(30) == true);
    assert((40):eq(40) == true);
    assert((10):eq(1) == false);
    assert((20):eq(2) == false);
    assert((30):eq(3) == false);
    assert((40):eq(4) == false);

    -- even (iseven)
    assert((1):even() == false);
    assert((2):even() == true);

    -- ge
    assert((1):ge(1) == true);
    assert((2):ge(1) == true);
    assert((1):ge(2) == false);

    -- gt
    assert((1):gt(1) == false);
    assert((2):gt(1) == true);
    assert((1):gt(2) == false);

    -- le
    assert((1):le(1) == true);
    assert((2):le(1) == false);
    assert((1):le(2) == true);

    -- lt
    assert((1):lt(1) == false);
    assert((2):lt(1) == false);
    assert((1):lt(2) == true);

    -- mod
    assert((20):mod(1) == 0);
    assert((30):mod(2) == 0);
    assert((40):mod(4) == 0);
    assert((21):mod(2) == 1);
    assert((21):mod(6) == 3);

    -- mul (mult, multiply)
    assert((20):mult(1) == 20);
    assert((30):mult(2) == 60);
    assert((40):mult(3) == 120);

    -- ne (neq, notequal, notequals)
    assert((10):ne(10) == false);
    assert((20):ne(20) == false);
    assert((30):ne(30) == false);
    assert((40):ne(40) == false);
    assert((10):ne(1) == true);
    assert((20):ne(2) == true);
    assert((30):ne(3) == true);
    assert((40):ne(4) == true);

    -- odd (isodd)
    assert((1):odd() == true);
    assert((2):odd() == false);

    -- sub (subtract)
    assert((20):sub(1) == 19);
    assert((30):sub(2) == 28);
    assert((40):sub(3) == 37);

    ----------------------------------------------------------------------------------------------------
    --
    -- Math Functions (Helpers)
    --
    ----------------------------------------------------------------------------------------------------

    -- d3dcolor
    assert(math.d3dcolor(255, 255, 255, 255) == 0xFFFFFFFF);
    assert(math.d3dcolor(255, 0, 0, 0) == 0xFF000000);
    assert(math.d3dcolor(255, 255, 0, 0) == 0xFFFF0000);
    assert(math.d3dcolor(255, 255, 0, 255) == 0xFFFF00FF);

    -- distance2d
    -- distance3d
    local x1, y1, z1 = 25.0, 25.0, 25.0;
    local x2, y2, z2 = 10.0, 10.0, 10.0;
    assert(math.distance2d(x1, y1, x2, y2):round(2) == 21.21);
    assert(math.distance3d(x1, y1, z1, x2, y2, z2):round(2) == 25.98);

    -- randomrng (randomrange, rndrng)
    for x = 1, 10 do
        assert(math.randomrng(5, 6):within(5, 6) == true);
        assert(math.randomrng(5, 6):within(1, 2) == false);
    end
end

--[[
*
* Tests     : Strings
* Module    : string.lua
*
--]]

do
    local str1 = '/derp arg1 this_is_arg2 "this is a quoted arg3" arg4 "quoted arg5" arg6';
    local str2 = ' Hello world. ';

    -- Metatable: __add
    assert('abc' + '123' == 'abc123');

    -- Metatable: __div
    assert(#('abcabc' / 2) == 3);
    assert(#('abcabc' / 3) == 2);

    -- Metatable: __index
    assert(str1[0] == #str1);
    assert(str1[0] == str1:len());
    assert(str1[1]:len() == 1);
    assert(str1[1] == '/');
    assert(str1[2] == 'd');
    assert(str1[1]:byte() == 47);

    -- Metatable: __mul
    assert('abc' * 2 == 'abcabc');
    assert(2 * 'abc' == 'abcabc');

    -- Metatable: __pow
    assert('abc' ^ 2 == 'abcabc');
    assert(2 ^ 'abc' == 'abcabc');

    -- Metatable: __sub
    assert(('test') - 2 == 'te');
    assert(2 - ('test') == 'st');
    assert(1 - ('!test!') - 1 == 'test');

    -- Metatable: __unm
    assert(-'abc' == 'cba');

    -- append
    assert(str2:append('123') == ' Hello world. 123');

    -- args
    local args = str1:args();
    assert(#args == 7);
    assert(args[1] == '/derp');
    assert(args[3] == 'this_is_arg2');
    assert(args[4] == 'this is a quoted arg3');
    assert(args[7] == 'arg6');

    -- argsquoted
    args = str1:argsquoted();
    assert(#args == 7);
    assert(args[1] == '/derp');
    assert(args[3] == 'this_is_arg2');
    assert(args[4] == '"this is a quoted arg3"');
    assert(args[7] == 'arg6');

    -- at
    assert(('test'):at(1) == 't');
    assert(('test'):at(2) == 'e');
    assert(('test'):at(3) == 's');
    assert(('test'):at(4) == 't');

    -- chars
    local c = str2:chars();
    assert(c[1] == ' ');
    assert(c[2] == 'H');

    -- clean
    assert(('  Test  '):clean() == 'Test');             -- Cleans all spaces..
    assert(('   Test   '):clean(false) == ' Test ');    -- Collapses to single spaces..

    -- clear
    assert(str2:clear() == '');

    -- collapse
    assert(('!    Test    !'):collapse() == '! Test !');
    assert(('!!!!!Test    !'):collapse('!') == '!Test    !');
    assert(('!!!!!Test    !    '):collapse('!') == '!Test    !    ');
    assert(('!!!!!Test    !    '):collapse('!', true) == '!Test    !');

    -- compare
    assert(('test'):compare('Test') == false);
    assert(('test'):compare('TeSt', true) == true);

    -- contains
    assert(str2:contains('H') == true);
    assert(str2:contains('!') == false);

    -- count
    assert(str2:count(('.'):escape()) == 1);    -- Escape pattern characters..
    assert(str2:count('%s') == 3);              -- Spaces..
    assert(str2:count('o') == 2);

    -- empty
    assert(str2:empty() == false);
    assert(str2:clear():empty() == true);

    -- enclose
    assert(str2:enclose('!') == '! Hello world. !');
    assert(str2:enclose('!', '@') == '! Hello world. @');

    -- enclosed
    assert(str2:enclosed('!') == false);
    assert(str2:enclosed(' ') == true);
    assert(str2:enclose('!'):enclosed('!') == true);
    assert(str2:enclose('!', '@'):enclosed('!', '@') == true);

    -- endswith
    assert(str2:endswith(' ') == true);
    assert(str2:enclose('!'):endswith('!') == true);

    -- escape
    assert(str2:escape() == ' Hello world%. ');

    -- expand
    assert(('Hello ${user}, the time is: ${time}.'):expand({ ['user'] = 'Tester', ['time'] = '11:30pm', }) == 'Hello Tester, the time is: 11:30pm.');

    -- fromhex
    assert(('74 65 73 74'):fromhex() == 'test');
    assert(('74657374'):fromhex() == 'test');
    assert(('0x740x650x730x74'):fromhex() == 'test');
    assert(('0x74 0x65 0x73 0x74'):fromhex() == 'test');
    assert(('0x74, 0x65, 0x73, 0x74'):fromhex() == 'test');

    -- hex
    assert(('test'):hex() == '74 65 73 74');
    assert(('test'):hex('') == '74657374');
    assert(('test'):hex('-') == '74-65-73-74');

    -- ieq
    assert(('test'):ieq('Test') == true);
    assert(('test'):ieq('TeSt') == true);

    -- insert(...)
    assert(('test'):insert(-1, '123') == 'tes123t');    -- Negative wrap-around index..
    assert(('test'):insert(0, '123') == 'test123');     -- Invalid index.. (Appends)
    assert(('test'):insert(1, '123') == '123test');
    assert(('test'):insert(2, '123') == 't123est');
    assert(('test'):insert(3, '123') == 'te123st');
    assert(('test'):insert(4, '123') == 'tes123t');
    assert(('test'):insert(5, '123') == 'test123');
    assert(('test'):insert(6, '123') == 'test123');     -- Invalid index.. (Appends)
    assert(('test'):insert(9, '123') == 'test123');     -- Invalid index.. (Appends)

    -- isalpha
    assert(str1:isalpha() == false);
    assert(str2:isalpha() == false);
    assert(('test'):isalpha() == true);

    -- isalphanumeric
    assert(str1:isalphanumeric() == false);
    assert(str2:isalphanumeric() == false);
    assert(('test1234'):isalphanumeric() == true);

    -- isdigit
    assert(str1:isdigit() == false);
    assert(str2:isdigit() == false);
    assert(('1234'):isdigit() == true);

    -- islower
    assert(('Test'):islower() == false);
    assert(('tesT'):islower() == false);
    assert(('TEST'):islower() == false);
    assert(('test'):islower() == true);

    -- isquoted
    assert(('test'):isquoted() == false);
    assert(('\'test'):isquoted() == false);     -- Expects matching double-quotes..
    assert(('\'test\''):isquoted() == false);   -- Expects matching double-quotes..
    assert(('"test'):isquoted() == false);      -- Expects matching double-quotes..
    assert(('"test"'):isquoted() == true);

    -- isspace
    assert(('test'):isspace() == false);
    assert((' '):isspace() == true);
    assert(('    '):isspace() == true);
    assert(('  test  '):isspace() == false);

    -- isupper
    assert(('Test'):isupper() == false);
    assert(('tesT'):isupper() == false);
    assert(('TEST'):isupper() == true);
    assert(('test'):isupper() == false);

    -- it
    local i = str2:it();
    assert(i() == ' ');
    assert(i() == 'H');
    assert(i() == 'e');
    assert(i() == 'l');

    -- join
    assert(('test'):join('-', 'a', 'b', 'c') == 'test-a-b-c');

    -- lfind
    assert(str2:lfind(' ') == 1);
    assert(str2:lfind('Hello') == 2);
    assert(str2:lfind('o') == 6);
    assert(str2:lfind('o', 7) == 9);
    assert(str2:lfind('o', 7, 8) == nil);

    -- lpad
    assert(('test'):lpad('!', 4) == 'test');
    assert(('test'):lpad('!', 5) == '!test');
    assert(('test'):lpad('!', 6) == '!!test');

    -- map
    assert(('test'):map(function () end) == 'test'); -- No return, original characters are returned..
    assert(('test'):map(function () return ''; end) == '');
    assert(('test'):map(function (c) return c; end) == 'test');

    -- number
    assert(('11'):number() == 11);
    assert(('22'):number() == 22);
    assert(('33'):number() == 33);
    assert(('11'):number(16) == 17);
    assert(('22'):number(16) == 34);
    assert(('33'):number(16) == 51);

    -- parts
    local str3 = '12345678';
    local parts = str3:parts(2);
    assert(#parts == 4);
    parts = str3:parts(3);
    assert(#parts == 3 and #parts[3] == 2); -- Uneven split, last part gets remainder..
    parts = str3:parts(4);
    assert(#parts == 2);

    -- prepend
    assert(('test'):prepend('123') == '123test');

    -- proper
    assert(('test'):proper() == 'Test');
    assert(('test test test'):proper() == 'Test Test Test');

    -- psplit
    assert(#str1:psplit('') == 71);
    assert(#str1:psplit(' ') == 12);
    assert(#str1:psplit('', 0, true) == 71);
    assert(#str1:psplit(' ', 0, true) == 23);
    assert(#str1:psplit('.') == 71);
    assert(#str1:psplit('%s+') == 12 );
    assert(#str1:psplit('.', 0, true) == 71);
    assert(#str1:psplit('%s+', 0, true) == 23);

    -- remove
    assert(('test'):remove(1) == 'est');
    assert(('test'):remove(2) == 'tst');
    assert(('test'):remove(3) == 'tet');
    assert(('test'):remove(4) == 'tes');

    -- replace
    assert(str2:replace('Hello', 'Goodbye') == ' Goodbye world. ');
    assert(('a a a a a'):replace('a', 'b', 2) == 'b b a a a');

    -- rfind
    assert(str2:rfind(' ') == 14);
    assert(str2:rfind(' ', 0, 13) == 7);
    assert(str2:rfind(' ', 0, 6) == 1);
    assert(str2:rfind('Hello') == 2);
    assert(str2:rfind('o') == 9);

    -- rpad
    assert(('test'):rpad('!', 4) == 'test');
    assert(('test'):rpad('!', 5) == 'test!');
    assert(('test'):rpad('!', 6) == 'test!!');

    -- slice
    assert(('test'):slice(1) == 'test');
    assert(('test'):slice(2) == 'est');
    assert(('test'):slice(3) == 'st');

    -- splice
    assert(('test'):splice(1, 1, 'zzz') == 'zzzest');
    assert(('test'):splice(1, 2, 'zzz') == 'zzzst');
    assert(('test'):splice(0, 0, 'zzz') == 'testzzztest');
    assert(('test'):splice(1, 0, 'zzz') == 'zzztest');

    -- split
    assert(#str1:split('') == 71);
    assert(#str1:split(' ') == 12);
    assert(#str1:split('', 0, true) == 71);
    assert(#str1:split(' ', 0, true) == 23);

    -- startswith
    assert(str2:startswith(' ') == true);
    assert(str2:enclose('!'):startswith('!') == true);

    -- strip
    assert(('!!!!test!!!!'):strip('!') == 'test');

    -- swapcase
    assert(('test'):swapcase() == 'TEST');
    assert(('teST SwApCaSe'):swapcase() == 'TEst sWaPcAsE');

    -- tostring
    assert(str1:tostring() == str1);

    -- totable
    local test_str = 'test';
    assert(#test_str:totable() == 4);
    assert(test_str:totable()[1] == string.byte('t'));
    assert(test_str:totable()[2] == string.byte('e'));

    -- trim
    assert(str2:trim() == 'Hello world.');
    assert(('!!!! test !!!!'):trim('!') == ' test ');

    -- trimex
    assert(str2:trimex() == 'Hello world.');
    assert(('   test   '):trimex() == 'test');

    -- trimend
    assert(str2:trimend() == ' Hello world.');
    assert(('!!!! test !!!!'):trimend('!') == '!!!! test ');

    -- trimstart
    assert(str2:trimstart() == 'Hello world. ');
    assert(('!!!! test !!!!'):trimstart('!') == ' test !!!!');

    -- type
    assert(str1:type() == 'string');
    assert(str2:type() == 'string');
    assert(('test'):type() == 'string');

    -- upperfirst
    assert(str2:upperfirst() == ' Hello world. ');
    assert(('test test'):upperfirst() == 'Test test');

    -- zerofill
    assert(('test'):zerofill(4) == 'test');
    assert(('test'):zerofill(5) == '0test');
    assert(('test'):zerofill(6) == '00test');
    assert(('test'):zerofill(7) == '000test');

    ----------------------------------------------------------------------------------------------------
    --
    -- String Functions (Final Fantasy XI Specific Helpers)
    --
    ----------------------------------------------------------------------------------------------------

    -- strip_colors
    local color_str = '\30\02This would be \31\244colored in FFXi.\30\01';
    assert(color_str:strip_colors() == 'This would be colored in FFXi.');

    -- strip_translate()
    -- TODO: Add test later..

    ----------------------------------------------------------------------------------------------------
    --
    -- String Functions (Base Method Aliases)
    --
    ----------------------------------------------------------------------------------------------------

    -- length
    local str4 = 'test';
    assert(str4:length() == 4);

    -- fmt
    assert(('Hello %s, %d == 1337.'):fmt('world', 1337) == 'Hello world, 1337 == 1337.');

    -- size
    str4 = 'test';
    assert(str4:size() == 4);
end

--[[
*
* Tests     : Tables
* Module    : table.lua
*
--]]

do
    -- Define some test tables..
    local t_nums    = T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, };
    local t_alpha   = T{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', };
    local t_mixed   = T{ 9, 'x', 4, 1, 'c', 7, 'r', 3, 8, 'v' };

    -- Define some helper functions..
    local is_even = function (a) return a % 2 == 0; end
    local is_odd = function (a) return a % 2 == 1; end
    local is_gt = function (a, b) return a > b; end
    local is_lt = function (a, b) return a < b; end

    -- all
    assert(T{ false, true, true }:all() == false);
    assert(T{ false, false, false }:all() == false);
    assert(T{ true, true, true }:all() == true);
    assert(T{ 2, 4, 6, 8 }:all(is_even) == true);
    assert(T{ 2, 4, 5, 6, 8 }:all(is_odd) == false);

    -- any
    assert(T{ false, true, true }:any() == true);
    assert(T{ false, false, false }:any() == false);
    assert(T{ true, true, true }:any() == true);
    assert(T{ 2, 4, 6, 8 }:any(is_even) == true);
    assert(T{ 2, 4, 5, 6, 8 }:any(is_odd) == true);
    assert(T{ 2, 4, 6, 8 }:any(is_odd) == false);

    -- append
    assert(T{ 2, 4, 6, 8 }:append(10):equals(T{ 2, 4, 6, 8, 10 }) == true);

    -- clear
    assert(T{ 2, 4, 6, 8 }:clear():empty() == true);

    -- contains
    assert(t_nums:contains(1) == true);
    assert(t_nums:contains(9) == true);
    assert(t_nums:contains(10) == false);
    assert(t_alpha:contains('a') == true);
    assert(t_alpha:contains('g') == true);
    assert(t_alpha:contains('z') == false);

    -- containskey
    local configs = T{
        ['color'] = { 0.0, 0.0, 0.0, 0.0 },
        ['font'] = {
            ['family'] = 'Arial',
            ['size'] = 14,
        },
        ['position'] = { 10.0, 25.0 },
    };
    assert(configs:containskey('color') == true);
    assert(configs:containskey('visible') == false);

    -- copy
    local t_nums_copy = t_nums:copy();
    t_nums_copy[1] = 99;
    assert(t_nums[1] == 1 and t_nums_copy[1] == 99);

    -- count
    assert(t_nums:count(1) == 1);
    assert(t_alpha:count('a') == 1);
    assert(t_mixed:count(1) == 1);
    assert(configs:count('visible') == 0);

    -- countf
    assert(t_nums:countf(is_even) == 4);
    assert(t_nums:countf(is_odd) == 5);

    -- delete
    t_nums_copy = t_nums:copy();
    local v = t_nums_copy:delete(3);
    assert(v == 3);
    assert(t_nums_copy:equals(T{ 1, 2, 4, 5, 6, 7, 8, 9, }));

    -- each
    local sum = 0;
    t_nums:each(function (v) sum = sum + v; end);
    assert(sum == 45);

    -- empty
    configs = T{
        ['empty1'] = { },
        ['empty2'] = T{ },
    };
    assert(t_nums:empty() == false);
    assert(T{}:empty() == true);
    assert(configs:empty(true) == true); -- Allows for empty child-tables.

    -- equals
    assert(t_nums:equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, }));
    assert(T{}:equals({}) == true);
    assert(T{}:equals(T{}) == true);

    -- extend
    assert(t_nums:copy():extend(11):equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, }));
    assert(t_nums:copy():extend({ 11, 12 }):equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, }));

    -- filter (Keeps keys from original table!)
    assert(t_nums:copy():filter(is_even):equals(T{ [2] = 2, [4] = 4, [6] = 6, [8] = 8, }));

    -- filteri (Rekeys the result as an array.)
    assert(t_nums:copy():filteri(is_even):equals(T{ 2, 4, 6, 8, }));

    -- find
    local fk, fv = t_nums:find(3);
    assert(fk == 3 and fv == 3);

    -- find_if
    fk, fv = t_nums:find_if(function (v, k) return v == 7 and k == 7; end);
    assert(fk == 7 and fv == 7);

    -- findkey
    fk, fv = t_nums:findkey(3);
    assert(fk == 3 and fv == 3);

    -- first
    assert(t_nums:first() == 1);
    assert(t_alpha:first() == 'a');

    -- flatten
    assert(T{ 1, 2, 3, T{ 4, 5, T{ 6, 7, }, }, }:flatten():equals(T{ 1, 2, 3, 4, 5, 6, 7, }));

    -- flip
    local t_flip = T{ [1] = 'a', [2] = 'b', [3] = 'c', }:flip();
    assert(t_flip:equals(T{ ['a'] = 1, ['b'] = 2, ['c'] = 3, }));

    -- imap
    assert(t_nums:copy():imap(function (v) return v + 1; end):equals(T{ 2, 3, 4, 5, 6, 7, 8, 9, 10, }));

    -- intersect
    local t_intersect1 = t_nums:intersect(t_mixed);         -- Intersect keys..
    local t_intersect2 = t_nums:intersect(t_mixed, true);   -- Intersect values..
    assert(t_intersect1:equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, }) == true);
    assert(t_intersect2:equals(T{ [1] = 1, [3] = 3, [4] = 4, [7] = 7, [8] = 8, [9] = 9, }) == true);

    -- isarray
    assert(t_nums:isarray() == true);           -- All in-order numeric keys..
    assert(t_intersect1:isarray() == true);     -- All in-order numeric keys..
    assert(t_intersect2:isarray() == false);    -- All numeric keys, but not in order..

    -- it
    sum = 0;
    for _, v in t_nums:it() do sum = sum + v; end
    assert(sum == 45);

    -- join
    assert(t_nums:join('') == '123456789');
    assert(t_nums:join(', ') == '1, 2, 3, 4, 5, 6, 7, 8, 9');

    -- keys
    assert(t_nums:keys():equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }));

    -- last
    assert(t_nums:last() == 9);
    assert(t_alpha:last() == 'g');

    -- length
    assert(t_nums:length() == 9);
    assert(t_alpha:length() == 7);

    -- map
    assert(t_nums:copy():map(function (v) return v + 1; end):equals(T{ 2, 3, 4, 5, 6, 7, 8, 9, 10, }));

    -- mapk
    assert(t_nums:copy():mapk(function (v) return v + 1; end):equals(T{ [2] = 1, [3] = 2, [4] = 3, [5] = 4, [6] = 5, [7] = 6, [8] = 7, [9] = 8, [10] = 9, }));

    -- max
    assert(t_nums:max() == 9);

    -- min
    assert(t_nums:min() == 1);

    -- mult
    assert(t_nums:mult() == 362880);

    -- merge
    local t_merge1 = T{ 1, 2, 3, 4 };
    local t_merge2 = T{ 9, 9, 9, 9 };
    assert(t_merge1:merge(t_merge2):equals(T{ 1, 2, 3, 4, }));          -- No updates by default..
    assert(t_merge1:merge(t_merge2, true):equals(T{ 9, 9, 9, 9, }));    -- Overwrites enabled..

    -- reduce
    local f_add = function (a, b) return a + b; end
    assert(t_nums:reduce(f_add) == 45);
    assert(t_nums:reduce(f_add, 1) == 46);

    -- reverse
    assert(t_nums:copy():reverse():equals(T{ 9, 8, 7, 6, 5, 4, 3, 2, 1, }));

    -- sort
    assert(T{ 1, 3, 5, 7, 9, 2, 4, 6, 8, }:sort():equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, }));
    assert(T{ 1, 3, 5, 7, 9, 2, 4, 6, 8, }:sort(is_lt):equals(T{ 1, 2, 3, 4, 5, 6, 7, 8, 9, }));
    assert(T{ 1, 3, 5, 7, 9, 2, 4, 6, 8, }:sort(is_gt):equals(T{ 9, 8, 7, 6, 5, 4, 3, 2, 1, }));

    -- sortkeys
    local t_sortkeys = T{ [1] = 1, [3] = 3, [5] = 5, [2] = 2, [4] = 4, [6] = 6, };
    assert(t_sortkeys:copy():sortkeys():equals(T{ 1, 2, 3, 4, 5, 6, }));
    assert(t_sortkeys:copy():sortkeys(is_gt):equals(T{ 6, 5, 4, 3, 2, 1, }));
    assert(t_sortkeys:copy():sortkeys(is_lt):equals(T{ 1, 2, 3, 4, 5, 6, }));

    -- slice
    local t_slice1 = t_nums:copy():slice(2, 4);
    local t_slice2 = t_nums:copy():slice(-6, 2);
    assert(t_slice1:equals(T{ 2, 3, 4, 5, }));
    assert(t_slice2:equals(T{ 4, 5, }));

    -- splice
    local t_splice1 = t_nums:copy();
    local splice_ret1 = t_splice1:splice(2, 4);             -- Simple removals..
    local t_splice2 = t_nums:copy();
    local splice_ret2 = t_splice2:splice(-6, 2);            -- Negative index removals..
    local t_splice3 = t_nums:copy();
    local splice_ret3 = t_splice3:splice(-6, 2, 11, 22);    -- Negative index removals with inserts..

    assert(t_splice1:equals(T{ 1, 6, 7, 8, 9, }));
    assert(splice_ret1:equals(T{ 2, 3, 4, 5, }));
    assert(t_splice2:equals(T{ 1, 2, 3, 6, 7, 8, 9, }));
    assert(splice_ret2:equals(T{ 4, 5, }));
    assert(t_splice3:equals(T{ 1, 2, 3, 11, 22, 6, 7, 8, 9, }));
    assert(splice_ret3:equals(T{ 4, 5, }));

    -- sum
    assert(t_nums:sum() == 45);

    -- transform
    local t_transform = t_nums:copy():transform(function (v) return v + 1; end);
    assert(t_transform:equals(T{ 2, 3, 4, 5, 6, 7, 8, 9, 10 }));

    -- unpack
    local r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 = t_nums:unpack();
    assert(r1 and r2 and r3 and r4 and r5 and r6 and r7 and r8 and r9 and r10 == nil);

    -- values
    local vals = t_mixed:values();
    assert(vals:equals(T{ 9, 'x', 4, 1, 'c', 7, 'r', 3, 8, 'v' }));

    ----------------------------------------------------------------------------------------------------
    --
    -- Table Functions (Helpers)
    --
    ----------------------------------------------------------------------------------------------------

    -- range
    assert(table.range(1, 5):equals(T{ 1, 2, 3, 4, 5, }));
    assert(table.range(5, 5):equals(T{ 5, }));
    assert(table.range(1, 10, 2):equals(T{ 1, 3, 5, 7, 9, }));
    assert(table.range(0, 10, 2):equals(T{ 0, 2, 4, 6, 8, 10, }));
end

--[[
*
* Tests     : Nil
* Module    : nil.lua
*
* Note:
*
*   This is tested last because of what it does.
*
*   This is considered dangerous! Please do not use this unless you know what you are doing!
*
*   Lua, by default, will raise an error if you attempt to call or index a nil value. This is good
*   practice to avoid unintended situations in code and should generally always be followed. This
*   feature will remove those restrictions of Lua and allow you to attempt to call a nil function,
*   index a nil object/value, etc.
*
*   This SHOULD NOT be used to avoid proper error handling.
*   This SHOULD NOT be used to avoid fixing problems with code.
*
*   Please do not use this unless you know what it does and what you are doing!
*
--]]

do
    -- Indexing nil here should fail..
    local s = nil;
    s = pcall(function () local o = nil; local v = o[1]; end);
    assert(s == false);
    s = pcall(function () local o = nil; o:test(); end);
    assert(s == false);
    s = pcall(function () local o = nil; o[1] = true; end);
    assert(s == false);

    -- Enable nil sugar..
    common.sugar.enable_nil_sugar();

    -- Indexing nil here should pass..
    s = pcall(function () local o = nil; local v = o[1]; end);
    assert(s == true);
    s = pcall(function () local o = nil; o:test(); end);
    assert(s == true);
    s = pcall(function () local o = nil; o[1] = true; end);
    assert(s == true);

    -- tostring()
    assert((nil):tostring() == 'nil');

    -- Disable nil sugar..
    common.sugar.disable_nil_sugar();

    -- Indexing nil here should fail..
    s = nil;
    s = pcall(function () local o = nil; local v = o[1]; end);
    assert(s == false);
    s = pcall(function () local o = nil; o:test(); end);
    assert(s == false);
    s = pcall(function () local o = nil; o[1] = true; end);
    assert(s == false);
end

print('\30\81[\30\06TestSugar\30\81] \30\106All tests completed!\30\01');