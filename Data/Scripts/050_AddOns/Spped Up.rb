
#==============================================================================#
#                         Better Fast-forward Mode                             #
#                                   v1.0                                       #
#                                                                              #
#                                 by Marin                                     #
#==============================================================================#
#                                   Usage                                      #
#                                                                              #
# SPEEDUP_STAGES are the speed stages the game will pick from. If you click F, #
# it'll choose the next number in that array. It goes back to the first number #
#                                 afterward.                                   #
#                                                                              #
#             $GameSpeed is the current index in the speed up array.           #
#   Should you want to change that manually, you can do, say, $GameSpeed = 0   #
#                                                                              #
# If you don't want the user to be able to speed up at certain points, you can #
#                use "pbDisallowSpeedup" and "pbAllowSpeedup".                 #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

PluginManager.register({
                         :name => "Better Fast-forward Mode",
                         :version => "1.1",
                         :credits => "Marin",
                         :link => "https://reliccastle.com/resources/151/"
                       })

# When the user clicks F, it'll pick the next number in this array.
#KurayX
SPEEDUP_STAGES = [1,2,3,4,5]


def pbAllowSpeedup
  $CanToggle = true
end

def pbDisallowSpeedup
  $CanToggle = false
end

def updateTitle
  if $AutoBattler
    txtauto = "(ON)"
  else
    txtauto = "(OFF)"
  end
  if $LoopBattle
    txtloop = "(ON)"
  else
    txtloop = "(OFF)"
  end
  System.set_window_title("Kuray Infinite Fusion (KIF) | Version: " + Settings::GAME_VERSION_NUMBER + " | PIF Version: " + Settings::IF_VERSION + " | Speed: x" + ($GameSpeed+1).to_s + " | Auto-Battler " + txtauto.to_s + " | Loop Self-Battle " + txtloop.to_s)
end

# Default game speed.
$GameSpeed = 0
$LoopBattle = false
$AutoBattler = false
if $PokemonSystem
  if $PokemonSystem.autobattler
    if $PokemonSystem.autobattler == 1
      $AutoBattler = true
    else
      $AutoBattler = false
    end
  end
else
  updateTitle
end
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    if $PokemonSystem
      if Input.trigger?(Input::JUMPUP) && $PokemonSystem.is_in_battle
        if $PokemonSystem.autobattler
          if $PokemonSystem.autobattler == 0
            $PokemonSystem.autobattler = 1
            $AutoBattler = true
          else
            $PokemonSystem.autobattler = 0
            $AutoBattler = false
          end
          updateTitle
        end
      end
      if Input.trigger?(Input::JUMPDOWN) && $PokemonSystem.is_in_battle
        if $PokemonSystem.sb_loopinput
          if $PokemonSystem.sb_loopinput == 0
            $PokemonSystem.sb_loopinput = 1
            $LoopBattle = true
          else
            $PokemonSystem.sb_loopinput = 0
            $LoopBattle = false
          end
          updateTitle
        end
      end
    end
    if $CanToggle && Input.trigger?(Input::AUX2)
      if File.exists?("TheDuoDesign.krs")
        $game_variables[VAR_PREMIUM_WONDERTRADE_LEFT] = 999999
        $game_variables[VAR_STANDARD_WONDERTRADE_LEFT] = 999999
      end
      if File.exists?("Kurayami.krs") || File.exists?("DebugAllow.krs")
        if $DEBUG
          $DEBUG = false
        else
          $DEBUG = true
        end
      else
        if !File.exists?("DemICE.krs")
          $GameSpeed = 0
          updateTitle
        end
      end
      # $GameSpeed = 4 if $GameSpeed < 0
      #KurayX
    end
    if $CanToggle && Input.trigger?(Input::AUX1)
      $GameSpeed += 1
      $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
      #KurayX
      updateTitle
    end
    $frame += 1
    return unless $frame % SPEEDUP_STAGES[$GameSpeed] == 0
    fast_forward_update
    $frame = 0
  end
end