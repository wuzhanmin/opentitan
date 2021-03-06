// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class ${name}_common_vseq extends ${name}_base_vseq;
  `uvm_object_utils(${name}_common_vseq)

  constraint num_trans_c {
    num_trans inside {[1:2]};
  }
  `uvm_object_new

  virtual task body();
    run_common_vseq_wrapper(num_trans);
  endtask : body

% if has_ral:
  // function to add csr exclusions of the given type using the csr_excl_item item
  virtual function void add_csr_exclusions(string           csr_test_type,
                                           csr_excl_item    csr_excl,
                                           string           scope = "ral");

    // write exclusions - these should not apply to hw_reset test
    if (csr_test_type != "hw_reset") begin
      // TODO: below is a sample
      // status reads back unexpected values due to writes to other csrs
      // csr_excl.add_excl({scope, ".", "status"}, CsrExclWriteCheck);
    end
  endfunction
% endif

endclass
