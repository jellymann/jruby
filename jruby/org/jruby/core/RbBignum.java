/*
 * RbBignum.java - No description
 * Created on 04. Juli 2001, 22:53
 * 
 * Copyright (C) 2001 Jan Arne Petersen, Stefan Matthias Aust, Alan Moore, Benoit Cerrina
 * Jan Arne Petersen <japetersen@web.de>
 * Stefan Matthias Aust <sma@3plus4.de>
 * Alan Moore <alan_moore@gmx.net>
 * Benoit Cerrina <b.cerrina@wanadoo.fr>
 * 
 * JRuby - http://jruby.sourceforge.net
 * 
 * This file is part of JRuby
 * 
 * JRuby is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * JRuby is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with JRuby; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

package org.jruby.core;

import org.jruby.*;
import org.jruby.exceptions.*;

/**
 *
 * @author  jpetersen
 */
public class RbBignum {
    public static RubyClass createBignum(Ruby ruby) {
        RubyClass bignumClass =
            ruby.defineClass("Bignum", ruby.getClasses().getIntegerClass());

        bignumClass.defineMethod("to_i", getMethod("m_to_i"));
        bignumClass.defineMethod("to_s", getMethod("m_to_s"));
        bignumClass.defineMethod("hash", getMethod("m_hash"));

        bignumClass.defineMethod("+", getMethod("op_plus", RubyObject.class));
        bignumClass.defineMethod("-", getMethod("op_minus", RubyObject.class));
        bignumClass.defineMethod("*", getMethod("op_mul", RubyObject.class));
        bignumClass.defineMethod("/", getMethod("op_div", RubyObject.class));
        bignumClass.defineMethod("%", getMethod("op_mod", RubyObject.class));
        bignumClass.defineMethod("**", getMethod("op_pow", RubyObject.class));

        bignumClass.defineMethod("==", getMethod("op_equal", RubyObject.class));
        bignumClass.defineMethod("<=>", getMethod("op_cmp", RubyObject.class));
        bignumClass.defineMethod(">", getMethod("op_gt", RubyObject.class));
        bignumClass.defineMethod(">=", getMethod("op_ge", RubyObject.class));
        bignumClass.defineMethod("<", getMethod("op_lt", RubyObject.class));
        bignumClass.defineMethod("<=", getMethod("op_le", RubyObject.class));

        return bignumClass;
    }

    private static Callback getMethod(String methodName) {
        return new ReflectionCallbackMethod(RubyBignum.class, methodName);
    }

    private static Callback getMethod(String methodName, Class arg1) {
        return new ReflectionCallbackMethod(RubyBignum.class, methodName, arg1);
    }
}