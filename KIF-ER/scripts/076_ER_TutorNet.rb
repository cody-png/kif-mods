#===============================================================================
# KIF: Elite Redux – ER tutor moves in KIF's Tutor.net (Cody, 2026-10-22: pay
# once each)
#   While Tutor.net is open (Moves applied), every ER tutor move a party
#   member can learn is listed at P10,000, Tutor.net's own tutor price. Paying
#   unlocks it for good (Tutor.net sets its price to 0). Moves not bought are
#   taken out again when Tutor.net closes, so the save only keeps the bought
#   ones. A tutor's own filtered list (pbTutorNetTutor) is left alone.
#===============================================================================
module KIFER
  module TutorNet
    PRICE = 10_000

    module_function

    def offers
      return [] unless $Trainer && $Trainer.party
      return $Trainer.party.flat_map { |p| KIFER::Moves.tutor_moves_for(p) }.uniq
    end

    # Adds the ER tutor moves Tutor.net doesn't list yet; returns them
    def add_offers
      return [] unless $Trainer && KIFER::Moves.applied?
      $Trainer.tutorlist ||= []
      have = $Trainer.tutorlist.map { |e| e.is_a?(Array) ? e[0] : e }
      added = offers - have
      added.each { |m| $Trainer.tutorlist.push([m, PRICE, "$"]) }
      return added
    end

    # Takes out the ones added above that weren't bought
    def drop_offers(added)
      return if added.empty? || !$Trainer || !$Trainer.tutorlist
      $Trainer.tutorlist.reject! { |e| e.is_a?(Array) && added.include?(e[0]) && e[1].to_i > 0 }
    end
  end
end

if defined?(PokemonTutorNetScreen)
  class PokemonTutorNetScreen
    alias kifer_tn_pbStartScreen pbStartScreen unless method_defined?(:kifer_tn_pbStartScreen)
    def pbStartScreen(movelist = [])
      added = (movelist.nil? || movelist.empty?) ? KIFER::TutorNet.add_offers : []
      begin
        return kifer_tn_pbStartScreen(movelist)
      ensure
        KIFER::TutorNet.drop_offers(added)
      end
    end
  end
end
