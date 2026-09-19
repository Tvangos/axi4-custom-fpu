#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "fpadd_ip_v1.h"
#include "sleep.h"

// Parameter definitions from your xparameters.h
#define INTC_DEVICE_ID          XPAR_PS7_SCUGIC_0_DEVICE_ID
#define BTNS_DEVICE_ID          XPAR_BTNS_5BIT_DEVICE_ID
#define SW_DEVICE_ID            XPAR_SW_8BIT_DEVICE_ID
#define INTC_GPIO_INTERRUPT_ID  XPAR_FABRIC_BTNS_5BIT_IP2INTC_IRPT_INTR
#define SLAVEREG0               XPAR_FPADD_IP_V1_0_S00_AXI_BASEADDR
#define BTN_INT                 XGPIO_IR_CH1_MASK

XGpio BTNInst;
XGpio SWInst;
XScuGic INTCInst;
static int btn_value;
static int sw_value;

// Prototypes
static void BTN_Intr_Handler(void *InstancePtr);
static int InterruptSystemSetup(XScuGic *XScuGicInstancePtr);
static int IntcInitFunction(u16 DeviceId, XGpio *GpioInstancePtr);


static int a_values[10] = {
    0x40000000, // 2.0
    0x3f800000, // 1.0
    0x45155e00, // 2389.875
    0x6ac49214, // 1.1882E+26
    0x6ac49214, // 1.1882E+26
    0x3fc7ae14, // 1.5599999
    0x4565ee8a, // 3678.90869
    0xc47a1ccd, // -1000.45001
    0x00000000, // 0.0
    0xbb908900  // -0.00441086
};

// Array for Operand B (Upper 32 bits of your Verilog memory_array)
static int b_values[10] = {
    0x3f800000, // 1.0
    0xbf800000, // -1.0
    0xc2de8000, // -111.25
    0x6b64b235, // 2.76477E+26
    0x2ac49214, // 3.491795E-13
    0xbfc66666, // -1.5499999
    0xc565ee8b, // -3678.90893
    0x447a4efa, // 1001.23400
    0x00000000, // 0.0
    0x38108900  // 3.445986E-05
};

static int position = 0; // To track which test case we are on;


void BTN_Intr_Handler(void *InstancePtr)
{
    // Disable GPIO interrupts to avoid nesting
    XGpio_InterruptDisable(&BTNInst, BTN_INT);

    // Check if the interrupt is actually from our button bank
    if ((XGpio_InterruptGetStatus(&BTNInst) & BTN_INT) != BTN_INT) {
        return;
    }

    // Read current hardware states
    btn_value = XGpio_DiscreteRead(&BTNInst, 1);
    sw_value = XGpio_DiscreteRead(&SWInst, 1);

	FPADD_IP_V1_mWriteReg(SLAVEREG0, 0, 0X0); // write 0 to the control register to disable the operation

	usleep(20000);
    // Top button. Move to the next set of values
	if((btn_value>>4) & 1) {
		position=(position+1)%10; // move to the next test case, wrap around after 10
		xil_printf("Pressed the up button! new value of position: %d\r\n", position);
		FPADD_IP_V1_mWriteReg(SLAVEREG0, 4, a_values[position]); // write operand A to the upper 32 bits of the memory array
		FPADD_IP_V1_mWriteReg(SLAVEREG0, 8, b_values[position]); // write operand B to the lower 32 bits of the memory array
    }
    // Down button. Go to prev set of values
    else if((btn_value>>1)&1) {
        position=(position-1+10)%10;
		xil_printf("Pressed the Down button! new value of position: %d\r\n", position);
		FPADD_IP_V1_mWriteReg(SLAVEREG0, 4, a_values[position]); // write operand A to the upper 32 bits of the memory array
		FPADD_IP_V1_mWriteReg(SLAVEREG0, 8, b_values[position]); // write operand B to the lower 32 bits of the memory array

    }
    else if((btn_value>>0)&1) {
    	xil_printf("Prepairing Data!\r\n");
    	usleep(1000000);
    	xil_printf("Data ready!\r\n");
    	FPADD_IP_V1_mWriteReg(SLAVEREG0, 0, 0x1); // write 1 to the control register to enable the operation
    }

	while(XGpio_DiscreteRead(&BTNInst, 1));
	usleep(20000);
	(void)XGpio_InterruptClear(&BTNInst, BTN_INT);
    XGpio_InterruptEnable(&BTNInst, BTN_INT);
}

int main (void)
{
    int status;
    xil_printf("--- System Initializing ---\r\n");

    // Initialize Buttons (Interrupt-Capable)
    status = XGpio_Initialize(&BTNInst, BTNS_DEVICE_ID);
    if(status != XST_SUCCESS) return XST_FAILURE;
    XGpio_SetDataDirection(&BTNInst, 1, 0xFF);

    // Initialize Switches (Polling only per xparameters)
    status = XGpio_Initialize(&SWInst, SW_DEVICE_ID);
    if(status != XST_SUCCESS) return XST_FAILURE;
    XGpio_SetDataDirection(&SWInst, 1, 0xFF);

    // Initialize Interrupt Controller
    status = IntcInitFunction(INTC_DEVICE_ID, &BTNInst);
    if(status != XST_SUCCESS) return XST_FAILURE;

    xil_printf("System Ready. Toggle switches and press buttons.\r\n");

    while(1); // Wait for interrupts
    return 0;
}

// Support functions remain the same as your source file
int InterruptSystemSetup(XScuGic *XScuGicInstancePtr)
{
    XGpio_InterruptEnable(&BTNInst, BTN_INT);
    XGpio_InterruptGlobalEnable(&BTNInst);
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                                 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                                 XScuGicInstancePtr);
    Xil_ExceptionEnable();
    return XST_SUCCESS;
}

int IntcInitFunction(u16 DeviceId, XGpio *GpioInstancePtr)
{
    XScuGic_Config *IntcConfig;
    IntcConfig = XScuGic_LookupConfig(DeviceId);
    XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
    InterruptSystemSetup(&INTCInst);
    XScuGic_Connect(&INTCInst, INTC_GPIO_INTERRUPT_ID,
                    (Xil_ExceptionHandler)BTN_Intr_Handler, (void *)GpioInstancePtr);
    XScuGic_Enable(&INTCInst, INTC_GPIO_INTERRUPT_ID);
    return XST_SUCCESS;
}
