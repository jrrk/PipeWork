-----------------------------------------------------------------------------------
--!     @file    pipe_core_unit.vhd
--!     @brief   PIPE CORE UNIT
--!     @version 1.5.0
--!     @date    2013/5/19
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--! @brief   PIPE CORE UNIT
-----------------------------------------------------------------------------------
entity  PIPE_CORE_UNIT is
    generic (
        PUSH_VALID          : --! @brief PUSH VALID :
                              --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PUSH_VALID>1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer :=  1;
        PULL_VALID          : --! @brief PUSH VALID :
                              --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PULL_VALID>1でデータ転送を行う.
                              --! * PULL_VALID=0でデータ転送を行わない.
                              integer :=  1;
        T_CLK_RATE          : --! @brief RESPONDER CLOCK RATE :
                              --! M_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)とリク
                              --! エスト側のクロック(M_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        M_CLK_RATE          : --! @brief REQUESTER CLOCK RATE :
                              --! T_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)とリク
                              --! エスト側のクロック(M_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        ADDR_BITS           : --! @brief Request Address Bits :
                              --! REQ_ADDR信号のビット数を指定する.
                              integer := 32;
        ADDR_VALID          : --! @brief Request Address Valid :
                              --! REQ_ADDR信号を有効にするかどうかを指定する.
                              --! * ADDR_VALID=0で無効.
                              --! * ADDR_VALID>0で有効.
                              integer :=  1;
        SIZE_BITS           : --! @brief Transfer Size Bits :
                              --! REQ_SIZE/ACK_SIZE信号のビット数を指定する.
                              integer := 32;
        SIZE_VALID          : --! @brief Request Size Valid :
                              --! REQ_SIZE信号を有効にするかどうかを指定する.
                              --! * SIZE_VALID=0で無効.
                              --! * SIZE_VALID>0で有効.
                              integer :=  1;
        MODE_BITS           : --! @brief Request Mode Bits :
                              --! REQ_MODE信号のビット数を指定する.
                              integer := 32;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        M_COUNT_BITS        : --! @brief Requester Flow Counter Bits :
                              integer := 12;
        T_COUNT_BITS        : --! @brief Responder Flow Counter Bits :
                              integer := 12;
        M_O_FIXED_CLOSE     : --! @brief OUTLET VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_O_FIXED_FLOW_OPEN : --! @brief OUTLET VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_O_FIXED_POOL_OPEN : --! @brief OUTLET FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_I_FIXED_CLOSE     : --! @brief INTAKE VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_I_FIXED_FLOW_OPEN : --! @brief INTAKE VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M_I_FIXED_POOL_OPEN : --! @brief INTAKE FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_O_FIXED_CLOSE     : --! @brief OUTLET VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_O_FIXED_FLOW_OPEN : --! @brief OUTLET VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_O_FIXED_POOL_OPEN : --! @brief OUTLET FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_I_FIXED_CLOSE     : --! @brief INTAKE VALVE FIXED CLOSE :
                              --! フローカウンタによるフロー制御を行わず、常に栓が
                              --! 閉じた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_I_FIXED_FLOW_OPEN : --! @brief INTAKE VALVE FLOW FIXED OPEN :
                              --! フローカウンタによるフロー制御を行わず、常にフロ
                              --! ー栓が開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        T_I_FIXED_POOL_OPEN : --! @brief INTAKE FIXED VALVE POOL OPEN :
                              --! プールカウンタによるフロー制御を行わず、常にプー
                              --! ル栓ルブが開いた状態にするか否かを指定する.
                              integer range 0 to 1 := 0;
        M2T_PUSH_RSV_VALID  : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に M_PUSH_RSV_SIZE を使うか 
                              --! M_PUSH_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        M2T_PULL_RSV_VALID  : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に M_PULL_RSV_SIZE を使うか 
                              --! M_PULL_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        M2T_PUSH_BUF_VALID  : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に M_PUSH_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        M2T_PULL_BUF_VALID  : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に M_PULL_BUF_SIZE を使うか 
                              --! M_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        M2T_PUSH_FIN_DELAY  : --! @brief Requester to Responder Pull Final Size Delay Cycle :
                              integer :=  0;
        T2M_PUSH_RSV_VALID  : --! @brief USE PUSH RESERVE SIGNALS :
                              --! フローカウンタの加算に T_PUSH_RSV_SIZE を使うか 
                              --! T_PUSH_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        T2M_PULL_RSV_VALID  : --! @brief USE PULL RESERVE SIGNALS :
                              --! フローカウンタの減算に T_PULL_RSV_SIZE を使うか 
                              --! T_PULL_FIX_SIZE を使うかを指定する.
                              integer range 0 to 1 := 0;
        T2M_PUSH_BUF_VALID  : --! @brief USE PUSH BUFFER  SIGNALS :
                              --! プールカウンタの加算に T_PUSH_BUF_SIZE を使うか 
                              --! T_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        T2M_PULL_BUF_VALID  : --! @brief USE PULL BUFFER  SIGNALS :
                              --! プールカウンタの減算に T_PULL_BUF_SIZE を使うか 
                              --! T_ACK_SIZE を使うかを指定する.
                              integer range 0 to 1 := 1;
        T2M_PUSH_FIN_DELAY  : --! @brief Responder to Requester Pull Final Size Delay Cycle :
                              integer :=  0;
        T_XFER_MAX_SIZE     : --! @brief Responder Transfer Max Size :
                              integer := 12
    );
    port (
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
        RST                 : --! @brief RESET :
                              --! 非同期リセット信号(ハイ・アクティブ).
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側クロック.
    -------------------------------------------------------------------------------
        T_CLK               : in  std_logic;
        T_CLR               : in  std_logic;
        T_CKE               : in  std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側からの要求信号入力.
    -------------------------------------------------------------------------------
        T_REQ_ADDR          : in  std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE          : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR       : in  std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE          : in  std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_DIR           : in  std_logic;
        T_REQ_FIRST         : in  std_logic;
        T_REQ_LAST          : in  std_logic;
        T_REQ_VALID         : in  std_logic;
        T_REQ_READY         : out std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側への応答信号出力.
    -------------------------------------------------------------------------------
        T_ACK_VALID         : out std_logic;
        T_ACK_NEXT          : out std_logic;
        T_ACK_LAST          : out std_logic;
        T_ACK_ERROR         : out std_logic;
        T_ACK_STOP          : out std_logic;
        T_ACK_SIZE          : out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- レスポンダ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        T_I_FLOW_LEVEL      : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_I_BUF_SIZE        : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_I_VALVE_OPEN      : in  std_logic;
        T_I_FLOW_READY      : out std_logic;
        T_I_FLOW_PAUSE      : out std_logic;
        T_I_FLOW_STOP       : out std_logic;
        T_I_FLOW_LAST       : out std_logic;
        T_I_FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_FIN_VALID    : in  std_logic;
        T_PUSH_FIN_LAST     : in  std_logic;
        T_PUSH_FIN_ERROR    : in  std_logic;
        T_PUSH_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_RSV_VALID    : in  std_logic;
        T_PUSH_RSV_LAST     : in  std_logic;
        T_PUSH_RSV_ERROR    : in  std_logic;
        T_PUSH_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_BUF_LEVEL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_BUF_RESET    : in  std_logic;
        T_PUSH_BUF_VALID    : in  std_logic;
        T_PUSH_BUF_LAST     : in  std_logic;
        T_PUSH_BUF_ERROR    : in  std_logic;
        T_PUSH_BUF_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- レスポンダ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        T_O_FLOW_LEVEL      : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_O_VALVE_OPEN      : in  std_logic;
        T_O_FLOW_READY      : out std_logic;
        T_O_FLOW_PAUSE      : out std_logic;
        T_O_FLOW_STOP       : out std_logic;
        T_O_FLOW_LAST       : out std_logic;
        T_O_FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_FIN_VALID    : in  std_logic;
        T_PULL_FIN_LAST     : in  std_logic;
        T_PULL_FIN_ERROR    : in  std_logic;
        T_PULL_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_RSV_VALID    : in  std_logic;
        T_PULL_RSV_LAST     : in  std_logic;
        T_PULL_RSV_ERROR    : in  std_logic;
        T_PULL_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_BUF_LEVEL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_BUF_RESET    : in  std_logic;
        T_PULL_BUF_VALID    : in  std_logic;
        T_PULL_BUF_LAST     : in  std_logic;
        T_PULL_BUF_ERROR    : in  std_logic;
        T_PULL_BUF_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_PULL_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- リクエスト側クロック.
    -------------------------------------------------------------------------------
        M_CLK               : in  std_logic;
        M_CLR               : in  std_logic;
        M_CKE               : in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側への要求信号出力.
    -------------------------------------------------------------------------------
        M_REQ_ADDR          : out std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE          : out std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR       : out std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE          : out std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_DIR           : out std_logic;
        M_REQ_FIRST         : out std_logic;
        M_REQ_LAST          : out std_logic;
        M_REQ_VALID         : out std_logic;
        M_REQ_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側からの応答信号入力.
    -------------------------------------------------------------------------------
        M_ACK_VALID         : in  std_logic;
        M_ACK_NEXT          : in  std_logic;
        M_ACK_LAST          : in  std_logic;
        M_ACK_ERROR         : in  std_logic;
        M_ACK_STOP          : in  std_logic;
        M_ACK_NONE          : in  std_logic;
        M_ACK_SIZE          : in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- リクエスタ側からデータ入力のフロー制御信号入出力.
    -------------------------------------------------------------------------------
        M_I_FLOW_PAUSE      : out std_logic;
        M_I_FLOW_STOP       : out std_logic;
        M_I_FLOW_LAST       : out std_logic;
        M_I_FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
        M_I_FLOW_READY      : out std_logic;
        M_I_FLOW_LEVEL      : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_I_BUF_SIZE        : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_FIN_VALID    : in  std_logic;
        M_PUSH_FIN_LAST     : in  std_logic;
        M_PUSH_FIN_ERROR    : in  std_logic;
        M_PUSH_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_RSV_VALID    : in  std_logic;
        M_PUSH_RSV_LAST     : in  std_logic;
        M_PUSH_RSV_ERROR    : in  std_logic;
        M_PUSH_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_BUF_LEVEL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_BUF_RESET    : in  std_logic;
        M_PUSH_BUF_VALID    : in  std_logic;
        M_PUSH_BUF_LAST     : in  std_logic;
        M_PUSH_BUF_ERROR    : in  std_logic;
        M_PUSH_BUF_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_BUF_READY    : out std_logic;
    -------------------------------------------------------------------------------
    -- リクエスタ側へのデータ出力のフロー制御信号入出力
    -------------------------------------------------------------------------------
        M_O_FLOW_PAUSE      : out std_logic;
        M_O_FLOW_STOP       : out std_logic;
        M_O_FLOW_LAST       : out std_logic;
        M_O_FLOW_SIZE       : out std_logic_vector(SIZE_BITS-1 downto 0);
        M_O_FLOW_READY      : out std_logic;
        M_O_FLOW_LEVEL      : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_FIN_VALID    : in  std_logic;
        M_PULL_FIN_LAST     : in  std_logic;
        M_PULL_FIN_ERROR    : in  std_logic;
        M_PULL_FIN_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_RSV_VALID    : in  std_logic;
        M_PULL_RSV_LAST     : in  std_logic;
        M_PULL_RSV_ERROR    : in  std_logic;
        M_PULL_RSV_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_BUF_LEVEL    : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_BUF_RESET    : in  std_logic;
        M_PULL_BUF_VALID    : in  std_logic;
        M_PULL_BUF_LAST     : in  std_logic;
        M_PULL_BUF_ERROR    : in  std_logic;
        M_PULL_BUF_SIZE     : in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_BUF_READY    : out std_logic
    );
end PIPE_CORE_UNIT;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.PIPE_COMPONENTS.PIPE_REQUESTER_INTERFACE;
use     PIPEWORK.PIPE_COMPONENTS.PIPE_RESPONDER_INTERFACE;
use     PIPEWORK.PIPE_COMPONENTS.PIPE_FLOW_SYNCRONIZER;
architecture RTL of PIPE_CORE_UNIT is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_req_start       : std_logic;
    signal    s_req_valid       : std_logic;
    signal    s_req_dir         : std_logic;
    signal    s_req_first       : std_logic;
    signal    s_req_last        : std_logic;
    signal    s_req_addr        : std_logic_vector(ADDR_BITS-1 downto 0);
    signal    s_req_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    s_req_mode        : std_logic_vector(MODE_BITS-1 downto 0);
    signal    s_req_buf_ptr     : std_logic_vector(BUF_DEPTH-1 downto 0);
    constant  s_req_ready       : std_logic := '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_res_start       : std_logic;
    signal    s_res_done        : std_logic;
    signal    s_res_error       : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_push_fin_valid  : std_logic;
    signal    s_push_fin_last   : std_logic;
    constant  s_push_fin_error  : std_logic := '0';
    signal    s_push_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    s_push_rsv_valid  : std_logic;
    signal    s_push_rsv_last   : std_logic;
    constant  s_push_rsv_error  : std_logic := '0';
    signal    s_push_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    s_pull_fin_valid  : std_logic;
    signal    s_pull_fin_last   : std_logic;
    constant  s_pull_fin_error  : std_logic := '0';
    signal    s_pull_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    s_pull_rsv_valid  : std_logic;
    signal    s_pull_rsv_last   : std_logic;
    constant  s_pull_rsv_error  : std_logic := '0';
    signal    s_pull_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_req_start       : std_logic;
    signal    q_req_dir         : std_logic;
    signal    q_req_first       : std_logic;
    signal    q_req_last        : std_logic;
    signal    q_req_addr        : std_logic_vector(ADDR_BITS-1 downto 0);
    signal    q_req_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    q_req_mode        : std_logic_vector(MODE_BITS-1 downto 0);
    signal    q_req_buf_ptr     : std_logic_vector(BUF_DEPTH-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_res_start       : std_logic;
    signal    q_res_done        : std_logic;
    signal    q_res_error       : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_push_fin_valid  : std_logic;
    signal    q_push_fin_last   : std_logic;
    constant  q_push_fin_error  : std_logic := '0';
    signal    q_push_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    q_push_rsv_valid  : std_logic;
    signal    q_push_rsv_last   : std_logic;
    constant  q_push_rsv_error  : std_logic := '0';
    signal    q_push_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    q_pull_fin_valid  : std_logic;
    signal    q_pull_fin_last   : std_logic;
    constant  q_pull_fin_error  : std_logic := '0';
    signal    q_pull_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    q_pull_rsv_valid  : std_logic;
    signal    q_pull_rsv_last   : std_logic;
    constant  q_pull_rsv_error  : std_logic := '0';
    signal    q_pull_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    T: PIPE_RESPONDER_INTERFACE 
        generic map (
            PUSH_VALID              => PUSH_VALID                  ,
            PULL_VALID              => PULL_VALID                  ,
            ADDR_BITS               => ADDR_BITS                   ,
            ADDR_VALID              => ADDR_VALID                  ,
            SIZE_BITS               => SIZE_BITS                   ,
            SIZE_VALID              => SIZE_VALID                  ,
            MODE_BITS               => MODE_BITS                   ,
            COUNT_BITS              => T_COUNT_BITS                ,
            BUF_DEPTH               => BUF_DEPTH                   ,
            O_FIXED_CLOSE           => T_O_FIXED_CLOSE             ,
            O_FIXED_FLOW_OPEN       => T_O_FIXED_FLOW_OPEN         ,
            O_FIXED_POOL_OPEN       => T_O_FIXED_POOL_OPEN         ,
            I_FIXED_CLOSE           => T_I_FIXED_CLOSE             ,
            I_FIXED_FLOW_OPEN       => T_I_FIXED_FLOW_OPEN         ,
            I_FIXED_POOL_OPEN       => T_I_FIXED_POOL_OPEN         ,
            USE_M_PUSH_RSV          => M2T_PUSH_RSV_VALID          ,
            USE_T_PULL_BUF          => T2M_PULL_BUF_VALID          ,
            USE_M_PULL_RSV          => M2T_PULL_RSV_VALID          ,
            USE_T_PUSH_BUF          => T2M_PUSH_BUF_VALID              
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                     => T_CLK                       , -- In  :
            RST                     => RST                         , -- In  :
            CLR                     => T_CLR                       , -- In  :
        ---------------------------------------------------------------------------
        -- Request from Responder Signals.
        ---------------------------------------------------------------------------
            T_REQ_ADDR              => T_REQ_ADDR                  , -- In  :
            T_REQ_SIZE              => T_REQ_SIZE                  , -- In  :
            T_REQ_BUF_PTR           => T_REQ_BUF_PTR               , -- In  :
            T_REQ_MODE              => T_REQ_MODE                  , -- In  :
            T_REQ_DIR               => T_REQ_DIR                   , -- In  :
            T_REQ_FIRST             => T_REQ_FIRST                 , -- In  :
            T_REQ_LAST              => T_REQ_LAST                  , -- In  :
            T_REQ_VALID             => T_REQ_VALID                 , -- In  :
            T_REQ_READY             => T_REQ_READY                 , -- Out :
        ---------------------------------------------------------------------------
        -- Acknowledge to Responder Signals.
        ---------------------------------------------------------------------------
            T_ACK_VALID             => T_ACK_VALID                 , -- Out :
            T_ACK_NEXT              => T_ACK_NEXT                  , -- Out :
            T_ACK_LAST              => T_ACK_LAST                  , -- Out :
            T_ACK_ERROR             => T_ACK_ERROR                 , -- Out :
            T_ACK_STOP              => T_ACK_STOP                  , -- Out :
            T_ACK_SIZE              => T_ACK_SIZE                  , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Valve Signals from Responder.
        ---------------------------------------------------------------------------
            T_PUSH_FIN_VALID        => T_PUSH_FIN_VALID            , -- In  :
            T_PUSH_FIN_LAST         => T_PUSH_FIN_LAST             , -- In  :
            T_PUSH_FIN_SIZE         => T_PUSH_FIN_SIZE             , -- In  :
            T_PUSH_BUF_LEVEL        => T_PUSH_BUF_LEVEL            , -- In  :
            T_PUSH_BUF_RESET        => T_PUSH_BUF_RESET            , -- In  :
            T_PUSH_BUF_VALID        => T_PUSH_BUF_VALID            , -- In  :
            T_PUSH_BUF_LAST         => T_PUSH_BUF_LAST             , -- In  :
            T_PUSH_BUF_SIZE         => T_PUSH_BUF_SIZE             , -- In  :
            T_PUSH_BUF_READY        => T_PUSH_BUF_READY            , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Valve Signals from Responder.
        ---------------------------------------------------------------------------
            T_PULL_FIN_VALID        => T_PULL_FIN_VALID            , -- In  :
            T_PULL_FIN_LAST         => T_PULL_FIN_LAST             , -- In  :
            T_PULL_FIN_SIZE         => T_PULL_FIN_SIZE             , -- In  :
            T_PULL_BUF_LEVEL        => T_PULL_BUF_LEVEL            , -- In  :
            T_PULL_BUF_RESET        => T_PULL_BUF_RESET            , -- In  :
            T_PULL_BUF_VALID        => T_PULL_BUF_VALID            , -- In  :
            T_PULL_BUF_LAST         => T_PULL_BUF_LAST             , -- In  :
            T_PULL_BUF_SIZE         => T_PULL_BUF_SIZE             , -- In  :
            T_PULL_BUF_READY        => T_PULL_BUF_READY            , -- Out :
        ---------------------------------------------------------------------------
        -- Requester Outlet Flow Signals.
        ---------------------------------------------------------------------------
            O_VALVE_OPEN            => T_O_VALVE_OPEN              , -- In  :
            O_FLOW_PAUSE            => T_O_FLOW_PAUSE              , -- Out :
            O_FLOW_STOP             => T_O_FLOW_STOP               , -- Out :
            O_FLOW_LAST             => T_O_FLOW_LAST               , -- Out :
            O_FLOW_SIZE             => T_O_FLOW_SIZE               , -- Out :
            O_FLOW_READY            => T_O_FLOW_READY              , -- Out :
            O_FLOW_LEVEL            => T_O_FLOW_LEVEL              , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Intake Flow Signals.
        ---------------------------------------------------------------------------
            I_VALVE_OPEN            => T_I_VALVE_OPEN              , -- In  :
            I_FLOW_PAUSE            => T_I_FLOW_PAUSE              , -- Out :
            I_FLOW_STOP             => T_I_FLOW_STOP               , -- Out :
            I_FLOW_LAST             => T_I_FLOW_LAST               , -- Out :
            I_FLOW_SIZE             => T_I_FLOW_SIZE               , -- Out :
            I_FLOW_READY            => T_I_FLOW_READY              , -- Out :
            I_FLOW_LEVEL            => T_I_FLOW_LEVEL              , -- In  :
            I_BUF_SIZE              => T_I_BUF_SIZE                , -- In  :
        ---------------------------------------------------------------------------
        -- Request to Requester Signals.
        ---------------------------------------------------------------------------
            M_REQ_START             => s_req_start                 , -- Out :
            M_REQ_ADDR              => s_req_addr                  , -- Out :
            M_REQ_SIZE              => s_req_size                  , -- Out :
            M_REQ_BUF_PTR           => s_req_buf_ptr               , -- Out :
            M_REQ_MODE              => s_req_mode                  , -- Out :
            M_REQ_DIR               => s_req_dir                   , -- Out :
            M_REQ_FIRST             => s_req_first                 , -- Out :
            M_REQ_LAST              => s_req_last                  , -- Out :
            M_REQ_VALID             => s_req_valid                 , -- Out :
            M_REQ_READY             => s_req_ready                 , -- In  :
        ---------------------------------------------------------------------------
        -- Response from Requester Signals.
        ---------------------------------------------------------------------------
            M_RES_START             => s_res_start                 , -- In  :
            M_RES_DONE              => s_res_done                  , -- In  :
            M_RES_ERROR             => s_res_error                 , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Valve Signals from Requester.
        ---------------------------------------------------------------------------
            M_PUSH_FIN_VALID        => s_push_fin_valid            , -- In  :
            M_PUSH_FIN_LAST         => s_push_fin_last             , -- In  :
            M_PUSH_FIN_SIZE         => s_push_fin_size             , -- In  :
            M_PUSH_RSV_VALID        => s_push_rsv_valid            , -- In  :
            M_PUSH_RSV_LAST         => s_push_rsv_last             , -- In  :
            M_PUSH_RSV_SIZE         => s_push_rsv_size             , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            M_PULL_FIN_VALID        => s_pull_fin_valid            , -- In  :
            M_PULL_FIN_LAST         => s_pull_fin_last             , -- In  :
            M_PULL_FIN_SIZE         => s_pull_fin_size             , -- In  :
            M_PULL_RSV_VALID        => s_pull_rsv_valid            , -- In  :
            M_PULL_RSV_LAST         => s_pull_rsv_last             , -- In  :
            M_PULL_RSV_SIZE         => s_pull_rsv_size               -- In  :
       );
    -------------------------------------------------------------------------------
    -- レスポンダ側からリクエスタ側へのリクエスト情報などを転送する.
    -------------------------------------------------------------------------------
    T2M: block
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO のビットの割り当てを保持する定数の型.
        ---------------------------------------------------------------------------
        type      OPEN_INFO_RANGE_TYPE is record
                  ADDR_LO           : integer;
                  ADDR_HI           : integer;
                  SIZE_LO           : integer;
                  SIZE_HI           : integer;
                  MODE_LO           : integer;
                  MODE_HI           : integer;
                  PTR_LO            : integer;
                  PTR_HI            : integer;
                  DIR_POS           : integer;
                  FIRST_POS         : integer;
                  LAST_POS          : integer;
                  BITS              : integer;
        end record;
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO のビットの割り当てを決める関数.
        ---------------------------------------------------------------------------
        function  SET_OPEN_INFO_RANGE return OPEN_INFO_RANGE_TYPE is
            variable param : OPEN_INFO_RANGE_TYPE;
            variable index : integer;
        begin
            -----------------------------------------------------------------------
            -- 必要な分だけビットを割り当てる.
            -----------------------------------------------------------------------
            index := 0;
            if (ADDR_VALID /= 0) then
                param.ADDR_LO := index;
                param.ADDR_HI := index + ADDR_BITS - 1;
                index := index + ADDR_BITS;
            end if;
            if (SIZE_VALID /= 0) then
                param.SIZE_LO := index;
                param.SIZE_HI := index + SIZE_BITS - 1;
                index := index + SIZE_BITS;
            end if;
            if (PUSH_VALID /= 0 and PULL_VALID /= 0) then
                param.DIR_POS := index;
                index := index + 1;
            end if;
            param.FIRST_POS := index;
            index := index + 1;
            param.LAST_POS  := index;
            index := index + 1;
            param.PTR_LO    := index;
            param.PTR_HI    := index + BUF_DEPTH - 1;
            index := index + BUF_DEPTH;
            param.MODE_LO   := index;
            param.MODE_HI   := index + MODE_BITS - 1;
            index := index + MODE_BITS;
            -----------------------------------------------------------------------
            -- この段階で必要な分のビット割り当ては終了.
            -----------------------------------------------------------------------
            param.BITS    := index;
            -----------------------------------------------------------------------
            -- 後は必要無いが、放っておくのも気持ち悪いので、ダミーの値をセット.
            -----------------------------------------------------------------------
            if (ADDR_VALID = 0) then
                param.ADDR_LO := index;
                param.ADDR_HI := index + ADDR_BITS - 1;
                index := index + ADDR_BITS;
            end if;
            if (SIZE_VALID = 0) then
                param.SIZE_LO := index;
                param.SIZE_HI := index + SIZE_BITS - 1;
                index := index + SIZE_BITS;
            end if;
            if (PUSH_VALID = 0 or PULL_VALID = 0) then
                param.DIR_POS := index;
                index := index + 1;
            end if;
            return param;
        end function;
        ---------------------------------------------------------------------------
        --! @brief OPEN_INFO のビットの割り当てを保持する定数.
        ---------------------------------------------------------------------------
        constant  OPEN_INFO_RANGE   : OPEN_INFO_RANGE_TYPE := SET_OPEN_INFO_RANGE;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数の型.
        ---------------------------------------------------------------------------
        type      SYNC_PARAM_TYPE   is record
                  PUSH_FIN_DELAY : integer;
                  PUSH_FIN_VALID : integer;
                  PUSH_RSV_VALID : integer;
                  PULL_FIN_VALID : integer;
                  PULL_RSV_VALID : integer;
        end record;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを決める関数.
        ---------------------------------------------------------------------------
        function  SET_SYNC_PARAM return SYNC_PARAM_TYPE is
            variable param : SYNC_PARAM_TYPE;
        begin
            if (M_O_FIXED_CLOSE = 0) then
                param.PUSH_FIN_DELAY := T2M_PUSH_FIN_DELAY;
                param.PUSH_FIN_VALID := 1;
                if (T2M_PUSH_RSV_VALID /= 0) then
                    param.PUSH_RSV_VALID := 1;
                else
                    param.PUSH_RSV_VALID := 0;
                end if;
            else
                param.PUSH_FIN_DELAY := 0;
                param.PUSH_FIN_VALID := 0;
                param.PUSH_RSV_VALID := 0;
            end if;
            if (M_I_FIXED_CLOSE = 0) then
                param.PULL_FIN_VALID := 1;
                if (T2M_PULL_RSV_VALID /= 0) then
                    param.PULL_RSV_VALID := 1;
                else
                    param.PULL_RSV_VALID := 0;
                end if;
            else
                param.PULL_FIN_VALID := 0;
                param.PULL_RSV_VALID := 0;
            end if;
            return param;
        end function;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数.
        ---------------------------------------------------------------------------
        constant  SYNC_PARAM        : SYNC_PARAM_TYPE := SET_SYNC_PARAM;
        ---------------------------------------------------------------------------
        --! @brief CLOSE_INFO のビットの割り当てを保持する定数.
        ---------------------------------------------------------------------------
        constant  CLOSE_INFO_BITS   : integer :=  1;
        ---------------------------------------------------------------------------
        -- 内部変数信号.
        ---------------------------------------------------------------------------
        signal    i_open_valid      : std_logic;
        signal    i_open_info       : std_logic_vector(OPEN_INFO_RANGE.BITS-1 downto 0);
        signal    i_close_valid     : std_logic;
        signal    i_close_info      : std_logic_vector(CLOSE_INFO_BITS     -1 downto 0);
        signal    o_open_valid      : std_logic;
        signal    o_open_info       : std_logic_vector(OPEN_INFO_RANGE.BITS-1 downto 0);
        signal    o_close_valid     : std_logic;
        signal    o_close_info      : std_logic_vector(CLOSE_INFO_BITS     -1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        I_ADDR_VALID_T: if (ADDR_VALID /= 0) generate
            i_open_info(OPEN_INFO_RANGE.ADDR_HI downto OPEN_INFO_RANGE.ADDR_LO) <= s_req_addr;
        end generate;
        I_SIZE_VALID_T: if (SIZE_VALID /= 0) generate
            i_open_info(OPEN_INFO_RANGE.SIZE_HI downto OPEN_INFO_RANGE.SIZE_LO) <= s_req_size;
        end generate;
        I_DIR_VALID_T : if (PUSH_VALID /= 0 and PULL_VALID /= 0) generate
            i_open_info(OPEN_INFO_RANGE.DIR_POS) <= s_req_dir;
        end generate;
        I_REQ_VALID_T : block begin
            i_open_valid  <= s_req_start;
            i_open_info(OPEN_INFO_RANGE.FIRST_POS) <= s_req_first;
            i_open_info(OPEN_INFO_RANGE.LAST_POS ) <= s_req_last;
            i_open_info(OPEN_INFO_RANGE.MODE_HI downto OPEN_INFO_RANGE.MODE_LO) <= s_req_mode;
            i_open_info(OPEN_INFO_RANGE.PTR_HI  downto OPEN_INFO_RANGE.PTR_LO ) <= s_req_buf_ptr;
            i_close_valid <= '0';
            i_close_info  <= (others => '0');
        end block;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SYNC: PIPE_FLOW_SYNCRONIZER
            generic map (
                I_CLK_RATE          => T_CLK_RATE                  , -- 
                O_CLK_RATE          => M_CLK_RATE                  , --
                OPEN_INFO_BITS      => OPEN_INFO_RANGE.BITS        , --
                CLOSE_INFO_BITS     => CLOSE_INFO_BITS             , --
                SIZE_BITS           => SIZE_BITS                   , --
                PUSH_FIN_VALID      => SYNC_PARAM.PUSH_FIN_VALID   , --
                PUSH_FIN_DELAY      => SYNC_PARAM.PUSH_FIN_DELAY   , --
                PUSH_RSV_VALID      => SYNC_PARAM.PUSH_RSV_VALID   , --
                PULL_FIN_VALID      => SYNC_PARAM.PULL_FIN_VALID   , --
                PULL_RSV_VALID      => SYNC_PARAM.PULL_RSV_VALID     --
            )                                                        -- 
            port map (                                               -- 
            ---------------------------------------------------------------------------
            -- Asyncronous Reset Signal.
            ---------------------------------------------------------------------------
                RST                 => RST                         , -- In  :
            ---------------------------------------------------------------------------
            -- Input
            ---------------------------------------------------------------------------
                I_CLK               => T_CLK                       , -- In  :
                I_CLR               => T_CLR                       , -- In  :
                I_CKE               => T_CKE                       , -- In  :
                I_OPEN_VAL          => i_open_valid                , -- In  :
                I_OPEN_INFO         => i_open_info                 , -- In  :
                I_CLOSE_VAL         => i_close_valid               , -- In  :
                I_CLOSE_INFO        => i_close_info                , -- In  :
                I_PUSH_FIN_VAL      => T_PUSH_FIN_VALID            , -- In  :
                I_PUSH_FIN_LAST     => T_PUSH_FIN_LAST             , -- In  :
                I_PUSH_FIN_SIZE     => T_PUSH_FIN_SIZE             , -- In  :
                I_PUSH_RSV_VAL      => T_PUSH_RSV_VALID            , -- In  :
                I_PUSH_RSV_LAST     => T_PUSH_RSV_LAST             , -- In  :
                I_PUSH_RSV_SIZE     => T_PUSH_RSV_SIZE             , -- In  :
                I_PULL_FIN_VAL      => T_PULL_FIN_VALID            , -- In  :
                I_PULL_FIN_LAST     => T_PULL_FIN_LAST             , -- In  :
                I_PULL_FIN_SIZE     => T_PULL_FIN_SIZE             , -- In  :
                I_PULL_RSV_VAL      => T_PULL_RSV_VALID            , -- In  :
                I_PULL_RSV_LAST     => T_PULL_RSV_LAST             , -- In  :
                I_PULL_RSV_SIZE     => T_PULL_RSV_SIZE             , -- In  :
            ---------------------------------------------------------------------------
            -- Output Clock and Clock Enable and Syncronous reset.
            ---------------------------------------------------------------------------
                O_CLK               => M_CLK                       , -- In  :
                O_CLR               => M_CLR                       , -- In  :
                O_CKE               => M_CKE                       , -- In  :
                O_OPEN_VAL          => o_open_valid                , -- Out :
                O_OPEN_INFO         => o_open_info                 , -- Out :
                O_CLOSE_VAL         => o_close_valid               , -- Out :
                O_CLOSE_INFO        => o_close_info                , -- Out :
                O_PUSH_FIN_VAL      => q_push_fin_valid            , -- Out :
                O_PUSH_FIN_LAST     => q_push_fin_last             , -- Out :
                O_PUSH_FIN_SIZE     => q_push_fin_size             , -- Out :
                O_PUSH_RSV_VAL      => q_push_rsv_valid            , -- Out :
                O_PUSH_RSV_LAST     => q_push_rsv_last             , -- Out :
                O_PUSH_RSV_SIZE     => q_push_rsv_size             , -- Out :
                O_PULL_FIN_VAL      => q_pull_fin_valid            , -- Out :
                O_PULL_FIN_LAST     => q_pull_fin_last             , -- Out :
                O_PULL_FIN_SIZE     => q_pull_fin_size             , -- Out :
                O_PULL_RSV_VAL      => q_pull_rsv_valid            , -- Out :
                O_PULL_RSV_LAST     => q_pull_rsv_last             , -- Out :
                O_PULL_RSV_SIZE     => q_pull_rsv_size               -- Out :
            );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        O_ADDR_VALID_T: if (ADDR_VALID /= 0) generate
            q_req_addr    <= o_open_info(OPEN_INFO_RANGE.ADDR_HI downto OPEN_INFO_RANGE.ADDR_LO);
        end generate;
        O_ADDR_VALID_F: if (ADDR_VALID  = 0) generate
            q_req_addr    <= (others => '0');
        end generate;
        O_SIZE_VALID_T: if (SIZE_VALID /= 0) generate
            q_req_size    <= o_open_info(OPEN_INFO_RANGE.SIZE_HI downto OPEN_INFO_RANGE.SIZE_LO);
        end generate;
        O_SIZE_VALID_F: if (SIZE_VALID  = 0) generate
            q_req_size    <= (others => '0');
        end generate;
        O_DIR_VALID_T : if (PUSH_VALID /= 0 and PULL_VALID /= 0) generate
            q_req_dir     <= o_open_info(OPEN_INFO_RANGE.DIR_POS);
        end generate;
        O_DIR_VALID_F : if (PUSH_VALID  = 0 or  PULL_VALID  = 0) generate
            q_req_dir     <= '1' when (PUSH_VALID /= 0) else '0';
        end generate;
        O_REQ_VALID_T : block begin
            q_req_start   <= o_open_valid;
            q_req_first   <= o_open_info(OPEN_INFO_RANGE.FIRST_POS);
            q_req_last    <= o_open_info(OPEN_INFO_RANGE.LAST_POS);
            q_req_buf_ptr <= o_open_info(OPEN_INFO_RANGE.PTR_HI  downto OPEN_INFO_RANGE.PTR_LO );
            q_req_mode    <= o_open_info(OPEN_INFO_RANGE.MODE_HI downto OPEN_INFO_RANGE.MODE_LO);
        end block;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M2T: block
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数の型.
        ---------------------------------------------------------------------------
        type      SYNC_PARAM_TYPE   is record
                  PUSH_FIN_DELAY : integer;
                  PUSH_FIN_VALID : integer;
                  PUSH_RSV_VALID : integer;
                  PULL_FIN_VALID : integer;
                  PULL_RSV_VALID : integer;
        end record;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを決める関数.
        ---------------------------------------------------------------------------
        function  SET_SYNC_PARAM return SYNC_PARAM_TYPE is
            variable param : SYNC_PARAM_TYPE;
        begin
            if (T_O_FIXED_CLOSE = 0) then
                param.PUSH_FIN_DELAY := M2T_PUSH_FIN_DELAY;
                param.PUSH_FIN_VALID := 1;
                if (M2T_PUSH_RSV_VALID /= 0) then
                    param.PUSH_RSV_VALID := 1;
                else
                    param.PUSH_RSV_VALID := 0;
                end if;
            else
                param.PUSH_FIN_DELAY := 0;
                param.PUSH_FIN_VALID := 0;
                param.PUSH_RSV_VALID := 0;
            end if;
            if (T_I_FIXED_CLOSE = 0) then
                param.PULL_FIN_VALID := 1;
                if (M2T_PULL_RSV_VALID /= 0) then
                    param.PULL_RSV_VALID := 1;
                else
                    param.PULL_RSV_VALID := 0;
                end if;
            else
                param.PULL_FIN_VALID := 0;
                param.PULL_RSV_VALID := 0;
            end if;
            return param;
        end function;
        ---------------------------------------------------------------------------
        --! @brief PIPE_FLOW_SYNCRONIZER のパラメータを保持する定数.
        ---------------------------------------------------------------------------
        constant  SYNC_PARAM        : SYNC_PARAM_TYPE := SET_SYNC_PARAM;
        signal    o_open_info       : std_logic_vector(0 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        SYNC: PIPE_FLOW_SYNCRONIZER                                  -- 
            generic map (                                            -- 
                I_CLK_RATE          => M_CLK_RATE                  , -- 
                O_CLK_RATE          => T_CLK_RATE                  , --
                OPEN_INFO_BITS      => 1                           , --
                CLOSE_INFO_BITS     => 1                           , --
                SIZE_BITS           => SIZE_BITS                   , --
                PUSH_FIN_VALID      => SYNC_PARAM.PUSH_FIN_VALID   , --
                PUSH_FIN_DELAY      => SYNC_PARAM.PUSH_FIN_DELAY   , --
                PUSH_RSV_VALID      => SYNC_PARAM.PUSH_RSV_VALID   , --
                PULL_FIN_VALID      => SYNC_PARAM.PULL_FIN_VALID   , --
                PULL_RSV_VALID      => SYNC_PARAM.PULL_RSV_VALID     --
            )                                                        -- 
            port map (                                               -- 
            ---------------------------------------------------------------------------
            -- Asyncronous Reset Signal.
            ---------------------------------------------------------------------------
                RST                 => RST                         , -- In  :
            ---------------------------------------------------------------------------
            -- Input
            ---------------------------------------------------------------------------
                I_CLK               => M_CLK                       , -- In  :
                I_CLR               => M_CLR                       , -- In  :
                I_CKE               => M_CKE                       , -- In  :
                I_OPEN_VAL          => q_res_start                 , -- In  :
                I_OPEN_INFO(0)      => q_res_start                 , -- In  :
                I_CLOSE_VAL         => q_res_done                  , -- In  :
                I_CLOSE_INFO(0)     => q_res_error                 , -- In  :
                I_PUSH_FIN_VAL      => M_PUSH_FIN_VALID            , -- In  :
                I_PUSH_FIN_LAST     => M_PUSH_FIN_LAST             , -- In  :
                I_PUSH_FIN_SIZE     => M_PUSH_FIN_SIZE             , -- In  :
                I_PUSH_RSV_VAL      => M_PUSH_RSV_VALID            , -- In  :
                I_PUSH_RSV_LAST     => M_PUSH_RSV_LAST             , -- In  :
                I_PUSH_RSV_SIZE     => M_PUSH_RSV_SIZE             , -- In  :
                I_PULL_FIN_VAL      => M_PULL_FIN_VALID            , -- In  :
                I_PULL_FIN_LAST     => M_PULL_FIN_LAST             , -- In  :
                I_PULL_FIN_SIZE     => M_PULL_FIN_SIZE             , -- In  :
                I_PULL_RSV_VAL      => M_PULL_RSV_VALID            , -- In  :
                I_PULL_RSV_LAST     => M_PULL_RSV_LAST             , -- In  :
                I_PULL_RSV_SIZE     => M_PULL_RSV_SIZE             , -- In  :
            ---------------------------------------------------------------------------
            -- Output Clock and Clock Enable and Syncronous reset.
            ---------------------------------------------------------------------------
                O_CLK               => T_CLK                       , -- In  :
                O_CLR               => T_CLR                       , -- In  :
                O_CKE               => T_CKE                       , -- In  :
                O_OPEN_VAL          => s_res_start                 , -- Out :
                O_OPEN_INFO         => o_open_info                 , -- Out :
                O_CLOSE_VAL         => s_res_done                  , -- Out :
                O_CLOSE_INFO(0)     => s_res_error                 , -- Out :
                O_PUSH_FIN_VAL      => s_push_fin_valid            , -- Out :
                O_PUSH_FIN_LAST     => s_push_fin_last             , -- Out :
                O_PUSH_FIN_SIZE     => s_push_fin_size             , -- Out :
                O_PUSH_RSV_VAL      => s_push_rsv_valid            , -- Out :
                O_PUSH_RSV_LAST     => s_push_rsv_last             , -- Out :
                O_PUSH_RSV_SIZE     => s_push_rsv_size             , -- Out :
                O_PULL_FIN_VAL      => s_pull_fin_valid            , -- Out :
                O_PULL_FIN_LAST     => s_pull_fin_last             , -- Out :
                O_PULL_FIN_SIZE     => s_pull_fin_size             , -- Out :
                O_PULL_RSV_VAL      => s_pull_rsv_valid            , -- Out :
                O_PULL_RSV_LAST     => s_pull_rsv_last             , -- Out :
                O_PULL_RSV_SIZE     => s_pull_rsv_size               -- Out :
            );
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M: PIPE_REQUESTER_INTERFACE 
        generic map (
            ADDR_BITS               => ADDR_BITS                   ,
            ADDR_VALID              => ADDR_VALID                  ,
            SIZE_BITS               => SIZE_BITS                   ,
            SIZE_VALID              => SIZE_VALID                  ,
            MODE_BITS               => MODE_BITS                   ,
            COUNT_BITS              => M_COUNT_BITS                ,
            BUF_DEPTH               => BUF_DEPTH                   ,
            T_XFER_MAX_SIZE         => T_XFER_MAX_SIZE             ,
            O_FIXED_CLOSE           => M_O_FIXED_CLOSE             ,
            O_FIXED_FLOW_OPEN       => M_O_FIXED_FLOW_OPEN         ,
            O_FIXED_POOL_OPEN       => M_O_FIXED_POOL_OPEN         ,
            I_FIXED_CLOSE           => M_I_FIXED_CLOSE             ,
            I_FIXED_FLOW_OPEN       => M_I_FIXED_FLOW_OPEN         ,
            I_FIXED_POOL_OPEN       => M_I_FIXED_POOL_OPEN         ,
            USE_T_PUSH_RSV          => T2M_PUSH_RSV_VALID          ,
            USE_M_PULL_BUF          => M2T_PULL_BUF_VALID          ,
            USE_T_PULL_RSV          => T2M_PULL_RSV_VALID          ,
            USE_M_PUSH_BUF          => M2T_PUSH_BUF_VALID             
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                     => M_CLK                       , -- In  :
            RST                     => RST                         , -- In  :
            CLR                     => M_CLR                       , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Request Signals.
        ---------------------------------------------------------------------------
            M_REQ_ADDR              => M_REQ_ADDR                  , -- Out :
            M_REQ_SIZE              => M_REQ_SIZE                  , -- Out :
            M_REQ_BUF_PTR           => M_REQ_BUF_PTR               , -- Out :
            M_REQ_MODE              => M_REQ_MODE                  , -- Out :
            M_REQ_DIR               => M_REQ_DIR                   , -- Out :
            M_REQ_FIRST             => M_REQ_FIRST                 , -- Out :
            M_REQ_LAST              => M_REQ_LAST                  , -- Out :
            M_REQ_VALID             => M_REQ_VALID                 , -- Out :
            M_REQ_READY             => M_REQ_READY                 , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Acknowledge Signals.
        ---------------------------------------------------------------------------
            M_ACK_VALID             => M_ACK_VALID                 , -- In  :
            M_ACK_NEXT              => M_ACK_NEXT                  , -- In  :
            M_ACK_LAST              => M_ACK_LAST                  , -- In  :
            M_ACK_ERROR             => M_ACK_ERROR                 , -- In  :
            M_ACK_STOP              => M_ACK_STOP                  , -- In  :
            M_ACK_NONE              => M_ACK_NONE                  , -- In  :
            M_ACK_SIZE              => M_ACK_SIZE                  , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            M_PULL_BUF_LEVEL        => M_PULL_BUF_LEVEL            , -- In  :
            M_PULL_BUF_RESET        => M_PULL_BUF_RESET            , -- In  :
            M_PULL_BUF_VALID        => M_PULL_BUF_VALID            , -- In  :
            M_PULL_BUF_LAST         => M_PULL_BUF_LAST             , -- In  :
            M_PULL_BUF_SIZE         => M_PULL_BUF_SIZE             , -- In  :
            M_PULL_BUF_READY        => M_PULL_BUF_READY            , -- Out :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            M_PUSH_BUF_LEVEL        => M_PUSH_BUF_LEVEL            , -- In  :
            M_PUSH_BUF_RESET        => M_PUSH_BUF_RESET            , -- In  :
            M_PUSH_BUF_VALID        => M_PUSH_BUF_VALID            , -- In  :
            M_PUSH_BUF_LAST         => M_PUSH_BUF_LAST             , -- In  :
            M_PUSH_BUF_SIZE         => M_PUSH_BUF_SIZE             , -- In  :
            M_PUSH_BUF_READY        => M_PUSH_BUF_READY            , -- Out :
        ---------------------------------------------------------------------------
        -- Requester Outlet Flow Signals.
        ---------------------------------------------------------------------------
            O_FLOW_READY            => M_O_FLOW_READY              , -- Out :
            O_FLOW_PAUSE            => M_O_FLOW_PAUSE              , -- Out :
            O_FLOW_STOP             => M_O_FLOW_STOP               , -- Out :
            O_FLOW_LAST             => M_O_FLOW_LAST               , -- Out :
            O_FLOW_SIZE             => M_O_FLOW_SIZE               , -- Out :
            O_FLOW_LEVEL            => M_O_FLOW_LEVEL              , -- In  :
        ---------------------------------------------------------------------------
        -- Requester Intake Flow Signals.
        ---------------------------------------------------------------------------
            I_FLOW_PAUSE            => M_I_FLOW_PAUSE              , -- Out :
            I_FLOW_STOP             => M_I_FLOW_STOP               , -- Out :
            I_FLOW_LAST             => M_I_FLOW_LAST               , -- Out :
            I_FLOW_SIZE             => M_I_FLOW_SIZE               , -- Out :
            I_FLOW_READY            => M_I_FLOW_READY              , -- Out :
            I_FLOW_LEVEL            => M_I_FLOW_LEVEL              , -- In  :
            I_BUF_SIZE              => M_I_BUF_SIZE                , -- In  :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            T_REQ_START             => q_req_start                 , -- In  :
            T_REQ_ADDR              => q_req_addr                  , -- In  :
            T_REQ_SIZE              => q_req_size                  , -- In  :
            T_REQ_BUF_PTR           => q_req_buf_ptr               , -- In  :
            T_REQ_FIRST             => q_req_first                 , -- In  :
            T_REQ_LAST              => q_req_last                  , -- In  :
            T_REQ_MODE              => q_req_mode                  , -- In  :
            T_REQ_DIR               => q_req_dir                   , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_RES_START             => q_res_start                 , -- Out :
            T_RES_DONE              => q_res_done                  , -- Out :
            T_RES_ERROR             => q_res_error                 , -- Out :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_PUSH_FIN_VALID        => q_push_fin_valid            , -- In  :
            T_PUSH_FIN_LAST         => q_push_fin_last             , -- In  :
            T_PUSH_FIN_ERR          => q_push_fin_error            , -- In  :
            T_PUSH_FIN_SIZE         => q_push_fin_size             , -- In  :
            T_PUSH_RSV_VALID        => q_push_rsv_valid            , -- In  :
            T_PUSH_RSV_LAST         => q_push_rsv_last             , -- In  :
            T_PUSH_RSV_ERR          => q_push_rsv_error            , -- In  :
            T_PUSH_RSV_SIZE         => q_push_rsv_size             , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            T_PULL_FIN_VALID        => q_pull_fin_valid            , -- In  :
            T_PULL_FIN_LAST         => q_pull_fin_last             , -- In  :
            T_PULL_FIN_ERR          => q_pull_fin_error            , -- In  :
            T_PULL_FIN_SIZE         => q_pull_fin_size             , -- In  :
            T_PULL_RSV_VALID        => q_pull_rsv_valid            , -- In  :
            T_PULL_RSV_LAST         => q_pull_rsv_last             , -- In  :
            T_PULL_RSV_ERR          => q_pull_rsv_error            , -- In  :
            T_PULL_RSV_SIZE         => q_pull_rsv_size               -- In  :
        );
end RTL;
