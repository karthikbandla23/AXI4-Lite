/////////////////////////////////////////////////////////////////////////
// axi4_lite_if.sv - Interface for AXI4 Lite Bus
//
// Description:
// ------------
// Defines the interface between master and slave of the AXI4 Lite bus.
/////////////////////////////////////////////////////////////////////////

// import the global definitions of AXI4 Lite bus
import axi4_lite_Defs::*;

interface axi4_lite_if;

logic ACLK;
logic ARESETN;
logic rd_en;
logic wr_en;
logic [Addr_Width - 1 : 0] Read_Address, Write_Address;
logic [Data_Width - 1 : 0]Write_Data;



// declare the signals in Read Address Channel


logic [Addr_Width-1:0] ARADDR;   // Read Address

logic ARVALID;                   // Read Address Valid, master generates this signal when the read address and the control signals are valid

logic ARREADY;                   // Read Address Ready, slave generates this signal when it can accept the read address and control signals


//declare the signals in Read Data Channel

logic [Data_Width-1:0] RDATA;    // Read Data 

logic RVALID;                    // Read valid, slave generate this signal when read data is valid 

logic RREADY;                    // Read Ready, master generates this signal when it can accept read data

logic RRESP;


// declare the signals in Write Address Channel 

 logic [Addr_Width-1:0] AWADDR;  // Write Address

 logic AWVALID;                  // Write Address valid, master generates this signal when write address and control signals are valid

 logic AWREADY;                  // Write Address Ready, slave generates this signal when it can accept write address and control signals


// declare the signals in Write Data Channel

logic [Data_Width-1:0] WDATA;     // Write Data 

logic WVALID;                     // Write Valid, master generates this signal when write data is valid

logic WREADY;                     // Write ready, slave generates this signal when it can accept write data


// declare the signals in Write Response Channel 

logic BVALID;                     // Write Response valid, slave generates this signal when write response on bus is valid.

logic BREADY;                     // Write Response Ready, master generates this signal when it can accept write response 

logic BRESP;

// declare the modport for master interface 

modport master_if (

input ARREADY,

input RDATA,

input RVALID,

input RRESP,

input AWREADY,

input BVALID,

input BRESP,

input ACLK,

input ARESETN,

output ARADDR,

output ARVALID,

output RREADY,

output AWADDR,

output AWVALID,

output WDATA,

output BREADY,

output WVALID,                     

input WREADY

);



// declare the modport for slave interface

modport slave_if (

output ARREADY,

output RDATA,

output RVALID,

output RRESP,

output AWREADY,

output BVALID,

output BRESP,

input ARADDR,

input ARVALID,

input RREADY,

input AWADDR,

input AWVALID,

input WDATA,

input BREADY,

input ACLK,

input ARESETN,

 input WVALID,                     

output WREADY

);



endinterface: axi4_lite_if