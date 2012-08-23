#pragma once 
#define REPORTID_TOUCH                          1
#define REPORTID_MOUSE                          2

static const uint8_t def_ReportDescriptor[] =
{
	0x05, 0x0d,                                                     //      USAGE_PAGE (Digitizers) 0
	0x09, 0x04,                                                             //      USAGE (Touch Screen) 2
	0xa1, 0x01,                                                             //      COLLECTION (Application) 4
	0x85, REPORTID_TOUCH,                   //              REPORT_ID (Touch) 6
	0x09, 0x20,                                                             //              USAGE (Stylus) 8
	0xa1, 0x00,                                                             //              COLLECTION (Physical) 10
	0x09, 0x42,                                                             //                      USAGE (Tip Switch) 12
	0x15, 0x00,                                                             //                      LOGICAL_MINIMUM (0) 14
	0x25, 0x01,                                                             //                      LOGICAL_MAXIMUM (1) 16
	0x75, 0x01,                                                             //                      REPORT_SIZE (1) 18
	0x95, 0x01,                                                             //                      REPORT_COUNT (1) 20
	0x81, 0x02,                                                             //                      INPUT (Data,Var,Abs) 22                                                         // 1 bit (tip)
	0x95, 0x03,                                                             //                      REPORT_COUNT (3) 24
	0x81, 0x03,                                                             //                      INPUT (Cnst,Ary,Abs) 26                                                         // 3 bits (padding)
	0x09, 0x32,                                                             //                      USAGE (In Range) 28
	0x09, 0x37,                                                             //                      USAGE (Data Valid-Finger) 30
	0x95, 0x02,                                                             //                      REPORT_COUNT (2) 32
	0x81, 0x02,                                                             //                      INPUT (Data,Var,Abs) 34                                                         // 2 bits (in range, data valid)
	0x95, 0x0a,                                                             //                      REPORT_COUNT (10) 36
	0x81, 0x03,                                                             //                      INPUT (Cnst,Ary,Abs) 38                                                         // 10 bits (padding)
	0x05, 0x01,                                                             //                      USAGE_PAGE (Generic Desktop) 40
	0x26, 0xff, 0x7f,                                       //                      LOGICAL_MAXIMUM (32767) 42
	0x75, 0x10,                                                             //                      REPORT_SIZE (16) 45
	0x95, 0x01,                                                             //                      REPORT_COUNT (1) 47
	0xa4,                                                                                   //                      PUSH 49
	0x55, 0x0d,                                                             //                      UNIT_EXPONENT (-3) 50
	0x65, 0x00,                                                             //                      UNIT (None) 52
	0x09, 0x30,                                                             //                      USAGE (X) 54
	0x35, 0x00,                                                             //                      PHYSICAL_MINIMUM (0) 56
	0x46, 0x00, 0x00,                                       //                      PHYSICAL_MAXIMUM (0) 58
	0x81, 0x02,                                                             //                      INPUT (Data,Var,Abs) 61                                                         // 16 bits (X)
	0x09, 0x31,                                                             //                      USAGE (Y) 63
	0x46, 0x00, 0x00,                                       //                      PHYSICAL_MAXIMUM (0) 65
	0x81, 0x02,                                                             //                      INPUT (Data,Var,Abs) 68                                                         // 16 bits (Y)
	0xb4,                                                                                   //                      POP 70
	0x05, 0x0d,                                                             //                      USAGE PAGE (Digitizers) 71
	0x09, 0x60,                                                             //                      USAGE (Width) 73
	0x09, 0x61,                                                             //                      USAGE (Height) 75
	0x95, 0x02,                                                             //                      REPORT_COUNT (2) 77
	0x81, 0x02,                                                             //                      INPUT (Data,Var,Abs) 79                                                         // 32 bits (width, height)
	0x95, 0x01,                                                             //                      REPORT_COUNT (1) 81
	0x81, 0x03,                                                             //                      INPUT (Cnst,Ary,Abs) 83/85                                              // 16 bits (padding)
	0xc0,                                                                                   //              END_COLLECTION 0/1

  // FEATURE REQUEST: TS_GET_DEVICE_TYPE
  0x85,0x80,                  // REPORT_ID (128)
  0x09,0x01,                  // USAGE (Vendor Usage 0x01)
  0x15,0x00,                  // LOGICAL_MINIMUM(0)
  0x47,0xff,0xff,0xff,0xff,   // LOGICAL_MAXIMUM(255)
	0x25,0x02,                  // LOGICAL_MAXIMUM (2)
	0x75,0x08,                  // REPORT_SIZE (8)
  0x95,0x01,                  // REPORT_COUNT (1)
  0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

  // FEATURE REQUEST: TS_GET_USB_MCU_VERSION
  0x85,0x81,                  // REPORT_ID (129)
  0x09,0x01,                  // USAGE (Vendor Usage 0x01)
  0x15,0x00,                  // LOGICAL_MINIMUM(0)
  0x47,0xff,0xff,0xff,0xff,   // LOGICAL_MAXIMUM(255)
  0x75,0x20,                  // REPORT_SIZE (32)
  0x95,0x01,                  // REPORT_COUNT (1)
  0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

	0x85,0xF0,                  // REPORT_ID (240)
	0x09,0x01,                  // USAGE (Vendor Usage 0x01)
	0x25,0x01,                  // LOGICAL_MAXIMUM(1)
	0x75,0x08,                  // REPORT_SIZE (8)
	0x95,0x02,                  // REPORT_COUNT (2)
	0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

//	0x85,0xF1,                  // REPORT_ID (241)
//	0x09,0x01,                  // USAGE (Vendor Usage 0x01)
//	0x27,0xff,0xff,0xff,0x7f,   // LOGICAL_MAXIMUM(2147483647)
//	0x75,0x20,                  // REPORT_SIZE (32)
//	0x95,0x01,                  // REPORT_COUNT (1)
//	0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

	0x85,0xF2,                  // REPORT_ID (242)
	0x09,0x01,                  // USAGE (Vendor Usage 0x01)
	0x25,0x08,                  // LOGICAL_MAXIMUM(8)
	0x75,0x08,                  // REPORT_SIZE (8)
	0x95,0x06,                  // REPORT_COUNT (1)
	0xB1,0x00,                  // FEATURE (Data,Ary,Abs)
#if 0
  0x09,0x01,                  // USAGE (Vendor Usage 0x01)
  0x26,0xff, 0x7f,            // LOGICAL_MAXIMUM(32767)
  0x75,0x20,                  // REPORT_SIZE (16)
  0x95,0x04,                  // REPORT_COUNT (4)
  0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

  0x85,0xF1,                                            // REPORT_ID (241)
  0x09,0x01,                  // USAGE (Vendor Usage 0x01)
  0x15,0x00,                  // LOGICAL_MINIMUM(0)
  0x47,0xff, 0xff, 0xff, 0x7f,// LOGICAL_MAXIMUM(2147483647)
  0x75,0x20,                  // REPORT_SIZE (32)
  0x95,0x08,                  // REPORT_COUNT (8)
  0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

	// feature report - read registers
	0x85,0x82,                  // REPORT_ID (130)
	0x09,0x01,                  // USAGE (Vendor Usage 0x01)
	0x15,0x00,                  // LOGICAL_MINIMUM(0)
	0x27,0xff,0xff,0xff,0x7f,   // LOGICAL_MAXIMUM(2147483647)
	0x75,0x20,                  // REPORT_SIZE (32)
	0x95,0x01,                  // REPORT_COUNT (1)
	0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

	0x85,0xF0,                  // REPORT_ID (240)
	0x09,0x01,                  // USAGE (Vendor Usage 0x01)
	0x25,0x01,                  // LOGICAL_MAXIMUM(1)
	0x75,0x08,                  // REPORT_SIZE (8)
	0x95,0x02,                  // REPORT_COUNT (2)
	0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

	0x85,0xF1,                  // REPORT_ID (241)
	0x09,0x01,                  // USAGE (Vendor Usage 0x01)
	0x27,0xff,0xff,0xff,0x7f,   // LOGICAL_MAXIMUM(2147483647)
	0x75,0x20,                  // REPORT_SIZE (32)
	0x95,0x01,                  // REPORT_COUNT (1)
	0xB1,0x00,                  // FEATURE (Data,Ary,Abs)

#endif
        0xc0,                                                                                   //      END_COLLECTION                                                                  
                                        // 96 bits = 12 bytes

	//
	// Dummy mouse collection starts here
	//
	0x05, 0x01,                         // USAGE_PAGE (Generic Desktop)     0
	0x09, 0x02,                         // USAGE (Mouse)                    2
	0xa1, 0x01,                         // COLLECTION (Application)         4
	0x85, REPORTID_MOUSE,               //   REPORT_ID (Mouse)              6
	0x09, 0x01,                         //   USAGE (Pointer)                8
	0xa1, 0x00,                         //   COLLECTION (Physical)          10
	0x05, 0x09,                         //     USAGE_PAGE (Button)          12
	0x19, 0x01,                         //     USAGE_MINIMUM (Button 1)     14
	0x29, 0x02,                         //     USAGE_MAXIMUM (Button 2)     16
	0x15, 0x00,                         //     LOGICAL_MINIMUM (0)          18
	0x25, 0x01,                         //     LOGICAL_MAXIMUM (1)          20
	0x75, 0x01,                         //     REPORT_SIZE (1)              22
	0x95, 0x02,                         //     REPORT_COUNT (2)             24
	0x81, 0x02,                         //     INPUT (Data,Var,Abs)         26
	0x95, 0x06,                         //     REPORT_COUNT (6)             28
	0x81, 0x03,                         //     INPUT (Cnst,Var,Abs)         30
	0x05, 0x01,                         //     USAGE_PAGE (Generic Desktop) 32
	0x09, 0x30,                         //     USAGE (X)                    34
	0x09, 0x31,                         //     USAGE (Y)                    36
	0x16, 0x00, 0x00,                   //     LOGICAL_MINIMUM (0)                  38
	0x26, 0xff, 0x7f,                                                                       //               LOGICAL_MAXIMUM (4095)
	0x75, 0x10,                         //     REPORT_SIZE (16)             42
	0x95, 0x02,                         //     REPORT_COUNT (2)             44
	0x81, 0x02,                         //     INPUT (Data,Var,ABs)         46
	0xc0,                               //   END_COLLECTION                 48
	0xc0,                               // END_COLLECTION                   49/50
};

