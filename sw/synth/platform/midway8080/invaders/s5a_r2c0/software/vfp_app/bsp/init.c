/*
 * $Id$
 */

/**
 * Configure the RTEMS initialisation.
 */

#include <stdlib.h>

#include <rtems.h>


/**
 * Configure base RTEMS resources.
 */
#define CONFIGURE_UNIFIED_WORK_AREAS

#define CONFIGURE_RTEMS_INIT_TASKS_TABLE
#define CONFIGURE_MEMORY_OVERHEAD                  512
#define CONFIGURE_MAXIMUM_TASKS                    rtems_resource_unlimited (10)
#define CONFIGURE_MAXIMUM_SEMAPHORES               rtems_resource_unlimited (10)
#define CONFIGURE_MAXIMUM_MESSAGE_QUEUES           0
#define CONFIGURE_MAXIMUM_PARTITIONS               0
#define CONFIGURE_MAXIMUM_TIMERS                   0

#define CONFIGURE_MAXIMUM_POSIX_THREADS             (20)
#define CONFIGURE_MAXIMUM_POSIX_TASKS               (20)
#define CONFIGURE_MAXIMUM_POSIX_MUTEXES             (100)
#define CONFIGURE_MAXIMUM_POSIX_CONDITION_VARIABLES (50)
#define CONFIGURE_MAXIMUM_POSIX_KEYS                (5)

/**
 * Configure drivers.
 */
#define CONFIGURE_MAXIMUM_DRIVERS                  10
#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER
#define CONFIGURE_MICROSECONDS_PER_TICK            1000
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER

/**
 * Configure file system and libblock.
 */
#define CONFIGURE_USE_DEVFS_AS_BASE_FILESYSTEM
#define CONFIGURE_LIBIO_MAXIMUM_FILE_DESCRIPTORS   5

/**
 * Tell confdefs.h to provide the configuration.
 */
#define CONFIGURE_INIT

#include <rtems/confdefs.h>
