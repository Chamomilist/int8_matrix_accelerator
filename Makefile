IVERILOG := iverilog -g2012
VVP      := vvp
RTL      := rtl
TB       := tb
RES      := results

TESTS := tb_multiplier tb_accumulator tb_mac tb_pe tb_matrix_buffer \
         tb_systolic_array tb_controller tb_top tb_top_scale

.PHONY: regression clean

regression:
	@mkdir -p $(RES)
	@pass=0; fail=0; \
	for t in $(TESTS); do \
		case $$t in \
			tb_multiplier)     deps="$(RTL)/multiplier.sv" ;; \
			tb_accumulator)    deps="$(RTL)/accumulator.sv" ;; \
			tb_mac)            deps="$(RTL)/multiplier.sv $(RTL)/accumulator.sv $(RTL)/mac.sv" ;; \
			tb_pe)             deps="$(RTL)/multiplier.sv $(RTL)/accumulator.sv $(RTL)/mac.sv $(RTL)/pe.sv" ;; \
			tb_matrix_buffer)  deps="$(RTL)/matrix_buffer.sv" ;; \
			tb_systolic_array) deps="$(RTL)/multiplier.sv $(RTL)/accumulator.sv $(RTL)/mac.sv $(RTL)/pe.sv $(RTL)/systolic_array.sv" ;; \
			tb_controller)     deps="$(RTL)/controller.sv" ;; \
			tb_top)            deps="$(RTL)/multiplier.sv $(RTL)/accumulator.sv $(RTL)/mac.sv $(RTL)/pe.sv $(RTL)/systolic_array.sv $(RTL)/matrix_buffer.sv $(RTL)/controller.sv $(RTL)/int8_matmul_top.sv" ;; \
			tb_top_scale)      deps="$(RTL)/multiplier.sv $(RTL)/accumulator.sv $(RTL)/mac.sv $(RTL)/pe.sv $(RTL)/systolic_array.sv $(RTL)/matrix_buffer.sv $(RTL)/controller.sv $(RTL)/int8_matmul_top.sv" ;; \
		esac; \
		if ! $(IVERILOG) -o $(RES)/$$t.out $$deps $(TB)/$$t.sv > $(RES)/$$t.compile.log 2>&1; then \
			echo "COMPILE FAIL | $$t"; fail=$$((fail+1)); continue; \
		fi; \
		$(VVP) $(RES)/$$t.out > $(RES)/$$t.log 2>&1; \
		if grep -q "ALL TESTS PASSED" $(RES)/$$t.log && ! grep -qE "FAIL|ERROR:" $(RES)/$$t.log; then \
			echo "PASS | $$t"; pass=$$((pass+1)); \
		else \
			echo "FAIL | $$t"; fail=$$((fail+1)); \
		fi; \
	done; \
	echo ""; \
	echo "========================================"; \
	echo " Regression: $$pass passed, $$fail failed"; \
	echo "========================================"; \
	[ $$fail -eq 0 ]

clean:
	rm -f $(RES)/*.out $(RES)/*.log $(RES)/*.vcd $(RES)/*.compile.log
