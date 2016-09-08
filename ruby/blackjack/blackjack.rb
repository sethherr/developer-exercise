class Array
  def where(args, chain = self)
    chain = where(args.drop(1), chain) if args.count > 1
    key, val = args.first[0], args.first[1]
    return chain.select { |i| i.send(key) == val } if first.respond_to?(key)
    return chain.select { |i| i[key] =~ val } if val.is_a?(Regexp)
    chain.select { |i| i[key] ==  val }
  end
end

class Card
  attr_accessor :suite, :name, :value

  def initialize(suite, name, value)
    @suite, @name, @value = suite, name, value
  end

  def display
    "#{@name} of #{@suite}"
  end
end

class Deck
  attr_accessor :playable_cards
  SUITES = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITES.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end
end

class Player
  attr_accessor :name, :cards, :won
  attr_writer :is_hitting
  attr_reader :is_dealer

  def initialize(is_dealer: false, name: nil)
    @is_dealer, @cards, @name, @won = is_dealer, [], name || (is_dealer && 'Dealer'), false
  end

  def is_hitting
    return false if bust
    @is_dealer ? (cards_maximum_value < 17) : @is_hitting
  end

  def visible_cards
    @is_dealer ? @cards.drop(1) : @cards
  end

  def receives_another_card
    return true if cards.size < 2
    return false if bust || blackjack
    is_hitting
  end

  def bust
    cards_minimum_value > 21
  end

  def blackjack
    return true if cards_maximum_value == 21 || cards_minimum_value == 21
    if @cards.where(name: :ace).count > 1 # Only need to test 1 high ace, 2 high always busts
      return true if cards_minimum_value + 10 == 21 # ... and 1 ace high is 10 bigger than min
    end
    false
  end

  def cards_minimum_value
    @cards.map { |c| c.value.is_a?(Array) ? c.value.min : c.value }.reduce(0, :+)
  end

  def cards_maximum_value
    @cards.map { |c| c.value.is_a?(Array) ? c.value.max : c.value }.reduce(0, :+)
  end
end

class Blackjack
  attr_accessor :finished
  attr_reader :players, :deck, :dealer, :non_dealer
  def initialize(player, dealer = nil)
    @deck, @finished, @non_dealer = Deck.new, false, player
    @dealer = dealer || Player.new(is_dealer: true)
    @players = [@non_dealer, @dealer]
  end

  def deal
    @non_dealer.cards << @deck.deal_card if @non_dealer.receives_another_card
    return if check_if_finished
    @dealer.cards << @deck.deal_card if @dealer.receives_another_card
    check_if_finished
  end

  def check_if_finished
    @non_dealer.won = @non_dealer.blackjack
    @non_dealer.won = @dealer.bust unless @non_dealer.won
    @dealer.won = @non_dealer.bust || !@non_dealer.won
    @finished = @non_dealer.won || @dealer.won
  end

  def dealer_finish
    @dealer.cards << @deck.deal_card until @dealer.receives_another_card
  end

  def start
    2.times { deal }
  end

  def display
    puts # get a clean line
    @players.each { |player| puts "#{player.name}: #{player.visible_cards.map(&:display).join(', ')}" }
  end
end
