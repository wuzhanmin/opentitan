// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class chip_env_cfg extends dv_base_env_cfg #(.RAL_T(chip_reg_block));

  bit                 stub_cpu;

  // chip top interfaces
  virtual clk_rst_if  usb_clk_rst_vif;
  gpio_vif            gpio_vif;
  mem_bkdr_vif        mem_bkdr_vifs[chip_mem_e];
  virtual pins_if#(1) srst_n_vif;
  virtual pins_if#(1) jtag_spi_n_vif;
  virtual pins_if#(1) bootstrap_vif;

  // sw msg monitor related
  sw_msg_monitor_vif  sw_msg_monitor_vif;
  // below values are constants, but made variables in case some test has different requirements
  string              rom_image         = "sw_build/rom/rom.vmem";
  string              rom_msg_data_file = "sw_build/rom/msg_data.txt";
  string              sw_image          = "sw_build/sw/sw.vmem";
  string              sw_msg_data_file  = "sw_build/sw/msg_data.txt";
  bit [TL_AW-1:0]     sw_msg_addr       = 32'h1000fff4;

  // ext component cfgs
  rand uart_agent_cfg m_uart_agent_cfg;
  rand jtag_agent_cfg m_jtag_agent_cfg;
  rand spi_agent_cfg  m_spi_agent_cfg;
  rand tl_agent_cfg   m_cpu_d_tl_agent_cfg;

  `uvm_object_utils_begin(chip_env_cfg)
    `uvm_field_int   (stub_cpu,             UVM_DEFAULT)
    `uvm_field_object(m_uart_agent_cfg,     UVM_DEFAULT)
    `uvm_field_object(m_jtag_agent_cfg,     UVM_DEFAULT)
    `uvm_field_object(m_spi_agent_cfg,      UVM_DEFAULT)
    `uvm_field_object(m_cpu_d_tl_agent_cfg, UVM_DEFAULT)
  `uvm_object_utils_end

  `uvm_object_new

  // TODO review value for csr_base_addr, csr_addr_map_size
  virtual function void initialize_csr_addr_map_size();
    this.csr_addr_map_size = 1 << TL_AW;
  endfunction : initialize_csr_addr_map_size

  virtual function void initialize(bit [TL_AW-1:0] csr_base_addr = '1);

    chip_mem_e mems[] = {Rom, FlashBank0, FlashBank1};

    super.initialize(csr_base_addr);
    // create uart agent config obj
    m_uart_agent_cfg = uart_agent_cfg::type_id::create("m_uart_agent_cfg");
    m_uart_agent_cfg.en_tx_monitor = 1'b0;
    m_uart_agent_cfg.en_rx_monitor = 1'b0;
    // create jtag agent config obj
    m_jtag_agent_cfg = jtag_agent_cfg::type_id::create("m_jtag_agent_cfg");
    // create spi agent config obj
    m_spi_agent_cfg = spi_agent_cfg::type_id::create("m_spi_agent_cfg");
    // create tl agent config obj
    m_cpu_d_tl_agent_cfg = tl_agent_cfg::type_id::create("m_cpu_d_tl_agent_cfg");
    m_cpu_d_tl_agent_cfg.if_mode = dv_utils_pkg::Host;
    // initialize the mem_bkdr_if vifs we want for this chip
    foreach(mems[mem]) begin
      mem_bkdr_vifs[mems[mem]] = null;
    end
  endfunction

  // ral flow is limited in terms of setting correct field access policies and reset values
  // We apply those fixes here - please note these fixes need to be reflected in the scoreboard
  protected virtual function void apply_ral_fixes();
    // Flash ctrl prog_empty interrupt is set to 1 out of reset since it really is empty.
    ral.flash_ctrl.intr_state.prog_empty.set_reset(1'b1);
    // Out of reset, the link is in disconnected state.
    ral.usbdev.intr_state.disconnected.set_reset(1'b1);
  endfunction

endclass
