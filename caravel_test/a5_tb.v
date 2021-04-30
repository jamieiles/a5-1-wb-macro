// SPDX-FileCopyrightText: 2020 Efabless Corporation, 2021 Jamie Iles
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"

module a5_tb;
    reg [8 * 4096:0] fst_filename;
    reg clock;
    reg RSTB;
    reg power1, power2;

    wire gpio;
    wire [37:0] mprj_io;

    always #10 clock <= (clock === 1'b0);

    initial begin
        clock = 0;
    end

    initial begin
        if (! $value$plusargs("fst_filename=%s", fst_filename)) begin
            $display("ERROR: please specify +fst_filename=<value> as an absolute path.");
            $finish;
        end
        $dumpfile(fst_filename);
        $dumpvars(0, a5_tb);

        wait(mprj_io[1:0] == 2'b00);
        $display("Management SoC initialized");
        wait(mprj_io[0]);

        if (mprj_io[1])
            $display("ERROR: test failed");
        $finish;
    end

    initial begin
        RSTB <= 1'b0;
        #1000;
        RSTB <= 1'b1;        // Release reset
        #2000;
    end

    initial begin        // Power-up sequence
        power1 <= 1'b0;
        power2 <= 1'b0;
        #200;
        power1 <= 1'b1;
        #200;
        power2 <= 1'b1;
    end

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;

    wire VDD1V8;
    wire VDD3V3;
    wire VSS;

    assign VDD3V3 = power1;
    assign VDD1V8 = power2;
    assign VSS = 1'b0;

    // Force CSB high
    assign mprj_io[3] = 1'b1;

    caravel uut (
        .vddio(VDD3V3),
        .vssio(VSS),
        .vdda(VDD3V3),
        .vssa(VSS),
        .vccd(VDD1V8),
        .vssd(VSS),
        .vdda1(VDD3V3),
        .vdda2(VDD3V3),
        .vssa1(VSS),
        .vssa2(VSS),
        .vccd1(VDD1V8),
        .vccd2(VDD1V8),
        .vssd1(VSS),
        .vssd2(VSS),
        .clock(clock),
        .gpio(gpio),
        .mprj_io(mprj_io),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .resetb(RSTB)
    );

    spiflash #(
        .FILENAME(`FIRMWARE_FILE)
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),
        .io3()
    );

endmodule
`default_nettype wire
