/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ART_RUNTIME_ARCH_MIPS_REGISTERS_MIPS_H_
#define ART_RUNTIME_ARCH_MIPS_REGISTERS_MIPS_H_

#include <iosfwd>

#include <android-base/logging.h>

#include "base/globals.h"
#include "base/macros.h"

namespace art {
namespace mips {

enum Register {
  ZERO =  0,
  AT   =  1,  // Assembler temporary.
  V0   =  2,  // Values.
  V1   =  3,
  A0   =  4,  // Arguments.
  A1   =  5,
  A2   =  6,
  A3   =  7,
  T0   =  8,  // Two extra arguments / temporaries.
  T1   =  9,
  T2   = 10,  // Temporaries.
  T3   = 11,
  T4   = 12,
  T5   = 13,
  T6   = 14,
  T7   = 15,
  S0   = 16,  // Saved values.
  S1   = 17,
  S2   = 18,
  S3   = 19,
  S4   = 20,
  S5   = 21,
  S6   = 22,
  S7   = 23,
  T8   = 24,  // More temporaries.
  T9   = 25,
  K0   = 26,  // Reserved for trap handler.
  K1   = 27,
  GP   = 28,  // Global pointer.
  SP   = 29,  // Stack pointer.
  FP   = 30,  // Saved value/frame pointer.
  RA   = 31,  // Return address.
  TR   = S1,  // ART Thread Register
  TMP  = T8,  // scratch register (in addition to AT)
  kNumberOfCoreRegisters = 32,
  kNoRegister = -1  // Signals an illegal register.
};
std::ostream& operator<<(std::ostream& os, const Register& rhs);

// Values for single-precision floating point registers.
enum FRegister {
  F0  =  0,
  F1  =  1,
  F2  =  2,
  F3  =  3,
  F4  =  4,
  F5  =  5,
  F6  =  6,
  F7  =  7,
  F8  =  8,
  F9  =  9,
  F10 = 10,
  F11 = 11,
  F12 = 12,
  F13 = 13,
  F14 = 14,
  F15 = 15,
  F16 = 16,
  F17 = 17,
  F18 = 18,
  F19 = 19,
  F20 = 20,
  F21 = 21,
  F22 = 22,
  F23 = 23,
  F24 = 24,
  F25 = 25,
  F26 = 26,
  F27 = 27,
  F28 = 28,
  F29 = 29,
  F30 = 30,
  F31 = 31,
  FTMP = F6,   // scratch register
  FTMP2 = F7,  // scratch register (in addition to FTMP, reserved for MSA instructions)
  kNumberOfFRegisters = 32,
  kNoFRegister = -1,
};
std::ostream& operator<<(std::ostream& os, const FRegister& rhs);

// Values for vector registers.
enum VectorRegister {
  W0  =  0,
  W1  =  1,
  W2  =  2,
  W3  =  3,
  W4  =  4,
  W5  =  5,
  W6  =  6,
  W7  =  7,
  W8  =  8,
  W9  =  9,
  W10 = 10,
  W11 = 11,
  W12 = 12,
  W13 = 13,
  W14 = 14,
  W15 = 15,
  W16 = 16,
  W17 = 17,
  W18 = 18,
  W19 = 19,
  W20 = 20,
  W21 = 21,
  W22 = 22,
  W23 = 23,
  W24 = 24,
  W25 = 25,
  W26 = 26,
  W27 = 27,
  W28 = 28,
  W29 = 29,
  W30 = 30,
  W31 = 31,
  kNumberOfVectorRegisters = 32,
  kNoVectorRegister = -1,
};
std::ostream& operator<<(std::ostream& os, const VectorRegister& rhs);

}  // namespace mips
}  // namespace art

#endif  // ART_RUNTIME_ARCH_MIPS_REGISTERS_MIPS_H_
