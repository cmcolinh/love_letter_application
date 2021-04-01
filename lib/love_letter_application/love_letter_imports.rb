#frozen string_literal: true

require 'change_orders'
require 'dry-auto_inject'
require 'dry-container'
require 'love_letter_application/actions/soldier'
require 'love_letter_application/actions/clown'
require 'love_letter_application/actions/knight'
require 'love_letter_application/actions/priestess'
require 'love_letter_application/actions/wizard'
require 'love_letter_application/actions/general'
require 'love_letter_application/actions/marquess'
require 'love_letter_application/actions/princess'
require 'love_letter_application/models/card'
require 'love_letter_application/models/effects/discard_and_draw'
require 'love_letter_application/models/effects/eliminate_player'
require 'love_letter_application/models/effects/make_player_not_targetable'
require 'love_letter_application/models/effects/next_player_draw_card'
require 'love_letter_application/models/effects/play_card'
require 'love_letter_application/models/effects/round_complete'
require 'love_letter_application/models/effects/switch_hands'
require 'love_letter_application/results/eliminate_player'
require 'love_letter_application/results/process_correct_guess'
require 'love_letter_application/results/process_draw_after_discard'
require 'love_letter_application/results/process_incorrect_guess'
require 'love_letter_application/results/process_knight_showdown'
require 'love_letter_application/results/process_next_player_turn'
require 'love_letter_application/results/process_next_turn_options'
require 'love_letter_application/results/process_princess_discarded'
require 'love_letter_application/results/process_resolve_wizard'
require 'love_letter_application/results/process_round_complete_by_depleted_deck'
require 'love_letter_application/results/process_round_complete_by_elimination'
require 'love_letter_application/results/process_switch_hands'
require 'love_letter_application/results/yield_to_block'
require 'love_letter_application/results/nodes/card_played_node'
require 'love_letter_application/results/nodes/card_viewed_node'
require 'love_letter_application/results/nodes/discard_card_node'
require 'love_letter_application/results/nodes/drawn_card_node'
require 'love_letter_application/results/nodes/eliminated_player_node'
require 'love_letter_application/results/nodes/hands_switched_node'
require 'love_letter_application/results/nodes/knight_drawn_node'
require 'love_letter_application/results/nodes/knight_victory_node'
require 'love_letter_application/results/nodes/log_node'
require 'love_letter_application/results/nodes/next_player_node'
require 'love_letter_application/results/nodes/play_card_with_no_args_option_node'
require 'love_letter_application/results/nodes/play_card_with_player_id_and_card_id_option_node'
require 'love_letter_application/results/nodes/play_card_with_player_id_option_node'
require 'love_letter_application/results/nodes/player_not_targetable_node'
require 'love_letter_application/results/nodes/princess_discarded_node'
require 'love_letter_application/results/nodes/result_game_board_node'
require 'love_letter_application/types/game_board'
require 'love_letter_application/validator/builder'
require 'love_letter_application/validator/get_legal_card_ids'
require 'love_letter_application/validator/get_legal_card_ids/marquess'
require 'love_letter_application/validator/play_card/builder'
require 'love_letter_application/validator/play_card/no_options'
require 'love_letter_application/validator/play_card/soldier/builder'
require 'love_letter_application/validator/play_card/select_target_player/builder'
require 'love_letter_application/validator/validate_card_id'

module LoveLetterApplication
  class DependencyContainer
    extend Dry::Container::Mixin
    namespace :love_letter_application do
      namespace :types do
        register :game_board do
          LoveLetterApplication::Types::GameBoard
        end
      end

      namespace :validator_builders do
        namespace :raw do
          no_options = LoveLetterApplication::Validator::PlayCard::NoOptions::new

          register :all do
            [ ->(**args, &block){},
              resolve(:soldier),
              resolve(:clown),
              resolve(:knight),
              resolve(:priestess),
              resolve(:wizard),
              resolve(:general),
              resolve(:marquess),
              resolve(:princess)
            ]
          end

          register :validate_card_combo_for do
            all_options_available = ->(card_list:){card_list.map{|card| card.id.to_i}}
            [ all_options_available,
              all_options_available, #card_id = 1
              all_options_available, #card_id = 2
              all_options_available, #card_id = 3
              all_options_available, #card_id = 4
              all_options_available, #card_id = 5
              all_options_available, #card_id = 6
              LoveLetterApplication::Validator::GetLegalCardIds::Marquess::new.method(:call),#id=7
              all_options_available  #card_id = 8
            ]
          end

          register :get_legal_card_ids do
            LoveLetterApplication::Validator::GetLegalCardIds::new(
              validate_card_combo_for: resolve(:validate_card_combo_for)).method(:call)
          end

          register :soldier do
            LoveLetterApplication::Validator::PlayCard::Soldier::Builder::new(
              no_options_validator: no_options).method(:call)
          end

          register :clown do
            LoveLetterApplication::Validator::PlayCard::SelectTargetPlayer::Builder::new(
              target_self?: false,
              no_options_validator: no_options).method(:call)
          end

          register :knight do
            resolve(:clown)
          end

          register :priestess do
            ->(model){no_options}
          end

          register :wizard do
            LoveLetterApplication::Validator::PlayCard::SelectTargetPlayer::Builder::new(
              target_self?: true,
              no_options_validator: no_options).method(:call)
          end

          register :general do
            resolve(:clown)
          end

          register :marquess do
            resolve(:priestess)
          end

          register :princess do
            resolve(:priestess)
          end
        end

        register :all do
          [ ->(**args){},
            resolve(:soldier),
            resolve(:clown),
            resolve(:knight),
            resolve(:priestess),
            resolve(:wizard),
            resolve(:general),
            resolve(:marquess),
            resolve(:princess)]
        end

        register :soldier do          
          soldier_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.soldier')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.soldier'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: soldier_action)}).method(:call)
        end

        register :clown do
          clown_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.clown')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.clown'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: clown_action)}).method(:call)
        end

        register :knight do
          knight_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.knight')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.knight'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: knight_action)}).method(:call)
        end

        register :priestess do
          priestess_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.priestess')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.priestess'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: priestess_action)}).method(:call)
        end

        register :wizard do
          wizard_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.wizard')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.wizard'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: wizard_action)}).method(:call)
        end

        register :general do
          general_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.general')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.general'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: general_action)}).method(:call)
        end

        register :marquess do
          marquess_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.marquess')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.marquess'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: marquess_action)}).method(:call)
        end

        register :princess do
          princess_action = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.actions.princess')
          LoveLetterApplication::Validator::PlayCard::Builder::new(
            build_raw_validator: resolve('raw.princess'),
            wrap_result: ->(successful_result){GameValidator::Validator::Result::new(
              result: successful_result,
              execute: princess_action)}).method(:call)
        end
      end

      register :change_orders_initializer do
        new_change_orders = ChangeOrders::Container::new
        ->{new_change_orders}
      end

      namespace :model_effects do
        register :discard_and_draw do
          LoveLetterApplication::Models::Effects::DiscardAndDraw::new(
            null_card: LoveLetterApplication::Models::Card::new(
              id: -1,
              rank: -1,
              targetable?: false)).method(:call)
        end

        register :eliminate_player_from_game_board do
          LoveLetterApplication::Models::Effects::EliminatePlayer::new.method(:call)
        end

        register :make_player_not_targetable do
          LoveLetterApplication::Models::Effects::MakePlayerNotTargetable::new.method(:call)
        end

        register :next_player_draw_card do
          LoveLetterApplication::Models::Effects::NextPlayerDrawCard::new.method(:call)
        end

        register :play_card do
          LoveLetterApplication::Models::Effects::PlayCard::new.method(:call)
        end

        register :round_complete do
          LoveLetterApplication::Models::Effects::RoundComplete::new.method(:call)
        end

        register :switch_hands do
          LoveLetterApplication::Models::Effects::SwitchHands::new.method(:call)
        end
      end

      namespace :results do
        register :eliminate_player do
          eliminate_player_from_game_board = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.eliminate_player_from_game_board')
          LoveLetterApplication::Results::EliminatePlayer::new(
            process_round_complete_by_elimination: resolve(:process_round_complete_by_elimination),
            get_next_player_turn: resolve(:get_next_player_node),
            eliminate_player_from_game_board: eliminate_player_from_game_board,
            process_next_player_turn: resolve(:process_next_player_turn),
            get_eliminated_player_node: resolve(:get_eliminated_player_node)).method(:call)
        end

        register :get_card_played_node do
          ->(player_id:, card_id:) do
            LoveLetterApplication::Results::Nodes::CardPlayedNode::new(
              player_id: player_id,
              card_id: card_id)
          end
        end

        register :get_card_viewed_node do
          ->(player_id:, target_player_id:, card_id:) do
            LoveLetterApplication::Results::Nodes::CardViewedNode::new(
              player_id: player_id,
              target_player_id: target_player_id,
              card_id: card_id)
          end
        end

        register :get_discard_card_node do
          ->(player_id:, card_id:) do
            LoveLetterApplication::Results::Nodes::DiscardCardNode::new(
              player_id: player_id,
              card_id: card_id)
          end
        end
 
        register :get_drawn_card_node do
          ->(player_id:, card_id:) do
            LoveLetterApplication::Results::Nodes::DrawnCardNode::new(
              player_id: player_id,
              card_id: card_id)
          end
        end

        register :get_eliminated_player_node do
          ->(player_id:) do
            LoveLetterApplication::Results::Nodes::EliminatedPlayerNode::new(player_id: player_id)
          end
        end

        register :get_hands_switched_node do
          ->(player_id:, target_player_id:, card_id_given:, card_id_taken:) do
            LoveLetterApplication::Results::Nodes::HandsSwitchedNode::new(
              player_id: player_id,
              target_player_id: target_player_id,
              card_id_given: card_id_given,
              card_id_taken: card_id_taken)
          end
        end   

        register :get_knight_victory_node do
          ->(winning_player_id:, losing_player_id:) do
            LoveLetterApplication::Results::Nodes::KnightVictoryNode::new(
              winning_player_id: winning_player_id,
              losing_player_id: losing_player_id)
          end
        end

        register :get_next_player_node do
          ->(player_id:) do
            LoveLetterApplication::Results::Nodes::NextPlayerNode::new(player_id: player_id)
          end
        end

        register :get_play_card_with_no_options_node do
          ->(card_id:) do
            LoveLetterApplication::Results::Nodes::PlayCardWithNoOptionsNode::new(card_id: card_id)
          end
        end

        register :get_play_card_with_player_id_and_card_id_option_node do
          ->(card_id:, player_id_list:, card_id_list:) do
            LoveLetterApplication::Results::Nodes::PlayCardWithPlayerIdAndCardIdOptionNode::new(
              card_id: card_id,
              player_id_list: player_id_list,
              card_id_list: card_id_list)
          end
        end

        register :get_play_card_with_player_id_option_node do
          ->(card_id:, player_id_list:) do
            LoveLetterApplication::Results::Nodes::PlayCardWithPlayerIdOptionNode::new(
              card_id: card_id,
              player_id_list: player_id_list)
          end
        end

        register :get_players_and_scores_node do
          ->(players_and_scores:) do
            LoveLetterApplication::Results::Nodes::PlayersAndScores::new(
              players_and_scores: players_and_scores)
          end
        end

        register :get_player_not_targetable_node do
          ->(player_id:) do
            LoveLetterApplication::Results::Nodes::PlayerNotTargetableNode::new(
              player_id: player_id)
          end
        end

        register :get_player_victory_node do
          ->(player_id:) do
            LoveLetterApplication::Results::Nodes::LogNode::new(
              message: "Player with id #{player_id} is the winner")
          end
        end

        register :get_princess_discarded_node do
          ->(player_id:) do
            LoveLetterApplication::Results::Nodes::PrincessDiscardedNode::new(
              player_id: player_id)
          end
        end

        register :get_result_game_board_node do
          ->(game_board:) do
            LoveLetterApplication::Results::Nodes::ResultGameBoardNode::new(game_board: game_board)
          end
        end

        register :knight_drawn_node do
          LoveLetterApplication::Results::Nodes::KnightDrawnNode::new
        end

        register :process_correct_guess do
          LoveLetterApplication::Results::ProcessCorrectGuess::new(
            log_correct_guess_node: LoveLetterApplication::Results::Nodes::LogNode::new(
              message: 'The guess is correct'),
            eliminate_player: resolve(:eliminate_player)).method(:call)
        end

        register :process_discard_passive_result do
          no_action = ::Types::Callable.call(LoveLetterApplication::Results::YieldToBlock::new)
          [ no_action,
            no_action, #card_id = 1
            no_action, #card_id = 2
            no_action, #card_id = 3
            no_action, #card_id = 4
            no_action, #card_id = 5
            no_action, #card_id = 6
            no_action, #card_id = 7
            resolve(:process_princess_discarded)] #card_id = 8
        end

        register :process_draw_after_discard do
          discard_and_draw = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.discard_and_draw')
          LoveLetterApplication::Results::ProcessDrawAfterDiscard::new(
            get_drawn_card_node: resolve(:get_drawn_card_node),
            discard_and_draw: discard_and_draw,
            process_next_player_turn: resolve(:process_next_player_turn)).method(:call)
        end

        register :process_incorrect_guess do
          LoveLetterApplication::Results::ProcessIncorrectGuess::new(
            log_incorrect_guess_node: LoveLetterApplication::Results::Nodes::LogNode::new(
              message: 'The guess is incorrect'),
            process_next_player_turn: resolve(:process_next_player_turn)).method(:call)
        end

        register :process_knight_showdown do
          LoveLetterApplication::Results::ProcessKnightShowdown::new(
            knight_drawn_node: resolve(:knight_drawn_node),
            get_knight_victory_node: resolve(:get_knight_victory_node),
            eliminate_player: resolve(:eliminate_player),
            process_next_player_turn: resolve(:process_next_player_turn)).method(:call)
        end

        register :process_next_player_turn do
          next_player_draw_card = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.next_player_draw_card')
          LoveLetterApplication::Results::ProcessNextPlayerTurn::new(
            process_round_complete_by_depleted_deck: resolve(:process_round_complete_by_depleted_deck),
            get_next_player_node: resolve(:get_next_player_node),
            get_drawn_card_node: resolve(:get_drawn_card_node),
            next_player_draw_card: next_player_draw_card,
            get_result_game_board_node: resolve(:get_result_game_board_node),
            process_next_turn_options: resolve(:process_next_turn_options)).method(:call)
        end

        register :process_next_turn_options do
          all_card_validator_builders = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.validator_builders.raw.all')
          get_legal_card_ids = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.validator_builders.raw.get_legal_card_ids')
          player_id_option = resolve(:get_play_card_with_player_id_option_node)
          player_card_id_option = resolve(:get_play_card_with_player_id_and_card_id_option_node)

          LoveLetterApplication::Results::ProcessNextTurnOptions::new(
            get_legal_card_ids: get_legal_card_ids,
            all_card_validator_builders: all_card_validator_builders,
            get_play_card_with_no_options_node: resolve(:get_play_card_with_no_options_node),
            get_play_card_with_player_id_option_node: player_id_option,
            get_play_card_with_player_id_and_card_id_option_node: player_card_id_option)
            .method(:call)
        end 

        register :process_princess_discarded do
          LoveLetterApplication::Results::ProcessPrincessDiscarded::new(
            get_princess_discarded_node: resolve(:get_princess_discarded_node),
            eliminate_player: resolve(:eliminate_player)).method(:call)
        end

        register :process_resolve_wizard do
          LoveLetterApplication::Results::ProcessResolveWizard::new(
            get_discard_card_node: resolve(:get_discard_card_node),
            process_discard_passive_result: resolve(:process_discard_passive_result),
            process_draw_after_discard: resolve(:process_draw_after_discard)).method(:call)
        end

        register :process_round_complete_by_depleted_deck do
          round_complete = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.round_complete')
          LoveLetterApplication::Results::ProcessRoundCompleteByDepletedDeck::new(
            log_deck_depleted_node: LoveLetterApplication::Results::Nodes::LogNode::new(
              message: 'Round is complete.  There are no more cards in the draw pile.'),
            get_players_and_scores_node: resolve(:get_players_and_scores_node),
            get_player_victory_node: resolve(:get_player_victory_node),
            round_complete: round_complete,
            get_result_game_board_node: resolve(:get_result_game_board_node)).method(:call)
        end

        register :process_round_complete_by_elimination do
          round_complete = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.round_complete')
          LoveLetterApplication::Results::ProcessRoundCompleteByElimination::new(
            log_all_opponents_eliminated_node: LoveLetterApplication::Results::Nodes::LogNode::new(
              message: 'Round is complete.  Only one player remains.'),
            get_player_victory_node: resolve(:get_player_victory_node),
            round_complete: round_complete,
            get_result_game_board_node: resolve(:get_result_game_board_node)).method(:call)
        end

        register :process_switch_hands do
          switch_hands = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.switch_hands')
          LoveLetterApplication::Results::ProcessSwitchHands::new(
            get_hands_switched_node: resolve(:get_hands_switched_node),
            switch_hands: switch_hands,
            process_next_player_turn: resolve(:process_next_player_turn)).method(:call)
        end
      end
 
      namespace :actions do
        register :get_card_played_node do
          LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.get_card_played_node')
        end

        register :play_card do 
          LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.play_card')
        end

        register :soldier do
          process_correct_guess = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_correct_guess')
          process_incorrect_guess = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_incorrect_guess') 
          LoveLetterApplication::Actions::Soldier::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            process_correct_guess: process_correct_guess,
            process_incorrect_guess: process_incorrect_guess).method(:call)
        end

        register :clown do
          get_card_viewed_node = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.get_card_viewed_node')
          process_next_player_turn = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_next_player_turn')
          LoveLetterApplication::Actions::Clown::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            get_card_viewed_node: get_card_viewed_node,
            process_next_player_turn: process_next_player_turn).method(:call)
        end

        register :knight do
          process_knight_showdown = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_knight_showdown')
          LoveLetterApplication::Actions::Knight::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            process_knight_showdown: process_knight_showdown).method(:call)
        end

        register :priestess do
          make_player_not_targetable = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.model_effects.make_player_not_targetable')
          get_player_not_targetable_node = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.get_player_not_targetable_node')
          process_next_player_turn = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_next_player_turn')
          LoveLetterApplication::Actions::Priestess::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            make_player_not_targetable: make_player_not_targetable,
            get_player_not_targetable_node: get_player_not_targetable_node,
            process_next_player_turn: process_next_player_turn).method(:call)
        end

        register :wizard do
          process_resolve_wizard = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_resolve_wizard')
          LoveLetterApplication::Actions::Wizard::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            process_resolve_wizard: process_resolve_wizard).method(:call)
        end

        register :general do
          process_switch_hands = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_switch_hands')
          LoveLetterApplication::Actions::General::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            process_switch_hands: process_switch_hands).method(:call)
        end

        register :marquess do
          process_next_player_turn = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.process_next_player_turn')
          LoveLetterApplication::Actions::Marquess::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            process_next_player_turn: process_next_player_turn).method(:call)
        end

        register :princess do
          get_princess_discarded_node = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.get_princess_discarded_node')
          eliminate_player = LoveLetterApplication::DependencyContainer
            .resolve('love_letter_application.results.eliminate_player')
          LoveLetterApplication::Actions::Princess::new(
            play_card: resolve(:play_card),
            get_card_played_node: resolve(:get_card_played_node),
            get_princess_discarded_node: get_princess_discarded_node,
            eliminate_player: eliminate_player).method(:call)
        end
      end

      register :build_validator do
        LoveLetterApplication::Validator::Builder::new(
          all_card_validator_builders: resolve('validator_builders.all'),
          get_legal_card_ids: resolve('validator_builders.raw.get_legal_card_ids'))
      end
    end
  end
end

LoveLetterApplication::LoveLetterImports = Dry::AutoInject(LoveLetterApplication::DependencyContainer)

