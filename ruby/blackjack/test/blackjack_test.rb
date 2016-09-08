require 'minitest/autorun'
require_relative '../blackjack'

require 'pp'

class CardTest < Minitest::Test
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suite_is_correct
    assert_equal @card.suite, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Minitest::Test
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end
  
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    assert !@deck.playable_cards.include?(card)
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end

class PlayerTest < Minitest::Test
  def setup
    @deck = Deck.new
  end

  def test_player_non_dealer_visible_cards
    player = Player.new(name: 'Bill Kaplan')
    player.cards = [@deck.deal_card, @deck.deal_card]
    assert_equal player.visible_cards.size, 2
  end

  def test_player_dealer_visible_cards
    dealer = Player.new(is_dealer: true)
    hole_card = @deck.deal_card
    dealer.cards = [hole_card, @deck.deal_card, @deck.deal_card]
    assert_equal dealer.visible_cards.size, 2
    assert !dealer.visible_cards.include?(hole_card)
  end

  def test_cards_minimum_value_with_ace_uses_1
    player = Player.new(name: 'Wizard')
    player.cards = [Card.new(:spades, :ace, [11, 1]), Card.new(:hearts, :two, 2)]
    assert_equal player.cards_minimum_value, 3
  end

  def test_player_busts_with_over_21
    player = Player.new(name: 'Benjamin')
    player.cards = [
      Card.new(:spades, :ace, [11, 1]),
      Card.new(:hearts, :two, 2),
      Card.new(:hearts, :ten, 10),
      Card.new(:hearts, :jack, 10)
    ]
    assert player.bust
  end

  def test_dealer_should_hit_below_17
    player = Player.new(is_dealer: true)
    player.cards = [
      Card.new(:hearts, :two, 2),
      Card.new(:hearts, :jack, 10)
    ]
    assert player.receives_another_card
  end

  def test_dealer_does_not_receive_card_over_17_with_ace
    player = Player.new(is_dealer: true)
    player.cards = [
      Card.new(:spades, :ace, [11, 1]),
      Card.new(:hearts, :six, 6)
    ]
    assert !player.receives_another_card
  end

  def test_player_receives_card_if_has_zero_cards
    player = Player.new(name: 'George')
    assert player.receives_another_card
  end

  def test_player_does_not_recieve_cards_if_bust
    player = Player.new
    player.cards = [
      Card.new(:clubs, :ten, 10),
      Card.new(:hearts, :king, 10),
      Card.new(:hearts, :king, 10)
    ]
    assert !player.receives_another_card
  end

  def test_player_does_not_recieve_cards_if_blackjack
    player = Player.new
    player.cards = [
      Card.new(:clubs, :ten, 10),
      Card.new(:hearts, :ace, [11, 1])
    ]
    assert !player.receives_another_card
  end

  def test_player_blackjacks_if_no_aces
    player = Player.new(name: 'Seth')
    player.cards = [
      Card.new(:spades, :ten, 10),
      Card.new(:clubs, :five, 5),
      Card.new(:hearts, :six, 6)
    ]
    assert player.blackjack
  end

  def test_player_blackjacks_if_possible_combination_is_21
    player = Player.new(name: 'Seth')
    player.cards = [
      Card.new(:spades, :eight, 9),
      Card.new(:clubs, :ace, [11, 1]),
      Card.new(:hearts, :ace, [11, 1])
    ]
    assert player.blackjack
  end
end

class BlackjackTest < Minitest::Test
  describe 'new game' do
    def setup
      @player = Player.new(name: 'Danny Ocean')
      @blackjack = Blackjack.new(@player)
    end

    def test_new_blackjack_has_deck_with_52_cards_and_a_dealer
      assert_equal @blackjack.deck.playable_cards.size, 52
      assert_equal @blackjack.players.size, 2
      assert @blackjack.players.where(is_dealer: true).size, 1
    end

    def test_dealing_deals_two_cards_to_each_player
      @blackjack.start
      assert @blackjack.players.map(&:cards).map(&:size), [2, 2]
    end
  end

  def test_player_loses_immediately_when_getting_cards
    player = Player.new(name: 'John')
    player.cards = [
      Card.new(:clubs, :ten, 10),
      Card.new(:hearts, :king, 10)
    ]
    blackjack = Blackjack.new(player)
    blackjack.start
    blackjack.deal
    blackjack.display
    assert blackjack.dealer.won
    assert !blackjack.player.won
  end
end
