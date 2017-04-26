require 'byebug'

class Level

  def initialize(level)
    @level = level
  end

  def play
    while count_free_crates > 0
      printf "\n%s\n\n> ", self
      c = gets
      c.each_byte do |command|
        # printf "#{command == ?w}"
        # noinspection RubyCaseWithoutElseBlockInspection
        case command.chr
          when ?w
            move(0,-1)
          when ?a
            move(-1,0)
          when ?s
            move(0,1)
          when ?d
            move(1,0)
          when ?r
            false # перезапустить уровень
        end
      end
    end
    printf "\n%s\nCongratulations, on the next level!\n", self
    true # уровень пройден
  end

  private

  def move(dx, dy)
    x,y = find_player

    # что находится в клетке, в которую хотим шагнуть
    dest = self[x+dx, y+dy]

    # noinspection RubyCaseWithoutElseBlockInspection
    case dest
      when ?#
        return
      # если перед нами стоит ящик (crate)
      when ?o, ?*
        # то смотрим, что находится за клеткой с ящиком
        dest2 = self[x+2*dx, y+2*dy]
        # если там пустота или storage - сдвигаем ящик туда
        if dest2.ord == 32
          self[x+2*dx, y+2*dy] = ?o
        elsif dest2 == ?.
          self[x+2*dx, y+2*dy] = ?*
        else
          return
        end
        dest = (dest == ?o) ? 32 : ?.
    end

    # byebug

    # меняем данные:
    # - в клетку, в которую хотим шагнуть, ставим героя.
    # - в клетку, из которой ушёл герой ставим:
    #   - или пробел - если там ничего нет
    #   - или "." - если там был storage

    self[x + dx, y + dy] = (dest.ord == 32) ? ?@ : ?+
    self[x,y] = (self[x,y] == ?@) ? 32 : ?.

  end

  def count_free_crates
    @level.scan(/o/).size
  end

  def find_player
    pos = @level.index(/[@+]/)
    return pos % 19, pos / 19
  end

  def [](x,y)
    @level[x + y*19]
  end

  def []=(x,y,v)
    @level[x + y*19] = v.chr
  end

  def to_s
    (0..16).map { |i| @level[i*19,19] }.join("\n")
  end

end

levels = File.readlines('levels.txt')
levels = levels.map { |line| line.chomp.ljust(19)}.join("\n")
levels = levels.split(/\n {19}\n/).map { |level| level.gsub(/\n/, '') }

levels.each do |level|
  redo unless Level.new(level.ljust(19*16)).play
end