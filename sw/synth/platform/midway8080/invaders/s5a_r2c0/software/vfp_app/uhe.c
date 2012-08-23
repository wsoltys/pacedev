/*
 * Catch any unhandled exception from the HAL layer.
 */

#include <stdint.h>

#include <system.h>
#include <sys/alt_exceptions.h>

#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API

unsigned int spurious_ints;

static alt_exception_result
unhandled_exception (alt_exception_cause cause,
                     uint32_t exception_pc,
                     uint32_t bad_addr)
{
  ++spurious_ints;
  return NIOS2_EXCEPTION_RETURN_REISSUE_INST;
}

#endif

void
init_uhe (void)
{
#ifdef ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
  alt_instruction_exception_register (unhandled_exception);
#endif
}
