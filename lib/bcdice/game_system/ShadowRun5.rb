# frozen_string_literal: true

require 'bcdice/game_system/ShadowRun4'

module BCDice
  module GameSystem
    class ShadowRun5 < ShadowRun4
      # ゲームシステムの識別子
      ID = 'ShadowRun5'

      # ゲームシステム名
      NAME = 'シャドウラン 5th Edition'

      # ゲームシステム名の読みがな
      SORT_KEY = 'しやとうらん5'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~INFO_MESSAGE_TEXT
        個数振り足しロール(xRn)の境界値を6にセット、バラバラロール(xBn)の目標値を5以上にセットします。
        バラバラロール(xBn)のみ、リミットをセットできます。リミットの指定は(xBn@l)のように指定します。(省略可)
        BコマンドとRコマンド時に、グリッチの表示を行います。
      INFO_MESSAGE_TEXT

      register_prefix('(\d+)B6@(\d+)')

      def initialize(command)
        super(command)
        @sort_add_dice = true
        @sort_barabara_dice = true
        @reroll_dice_reroll_threshold = 6 # RerollDiceで振り足しをする出目の閾値

        @default_cmp_op = :>=
        @default_target_number = 5
      end

      # シャドウラン5版　リミット時のテスト
      def eval_game_system_specific_command(command)
        debug('chatch limit prefix')

        m = /(\d+B6)@(\d+)/.match(command)
        b_dice = m[1]
        limit = m[2].to_i
        output_before_limited = BCDice::CommonCommand::BarabaraDice.eval(b_dice, self, @randomizer).text

        m = /成功数(\d+)/.match(output_before_limited)
        output_after_limited = output_before_limited
        before_suc_cnt = m[1].to_i
        if before_suc_cnt > limit
          after_suc_cnt = limit
          over_suc_cnt = before_suc_cnt - limit
          output_after_limited = output_before_limited.gsub(/成功数(\d+)/, "成功数#{after_suc_cnt}")
          output_after_limited += "(リミット超過#{over_suc_cnt})"
        end

        output = output_after_limited
        output = output.gsub('B', 'B6')
        output = output.gsub('6>=5', "[6]Limit[#{limit}]>=5")
        debug(output)
        return output
      end

      # シャドウラン5版用グリッチ判定
      def grich_text(numberSpot1, dice_cnt_total, successCount)
        dice_cnt_total_half = dice_cnt_total.to_f / 2
        debug("dice_cnt_total_half", dice_cnt_total_half)

        unless numberSpot1 > dice_cnt_total_half
          return nil
        end

        # グリッチ！
        if successCount == 0
          'クリティカルグリッチ'
        else
          'グリッチ'
        end
      end
    end
  end
end
