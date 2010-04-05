class String

  # Replace sequences of whitespace (including newlines) with either
  # a single space or remove them entirely (according to param _spaced_)
  #
  #   <<QUERY.compress_lines
  #     SELECT name
  #     FROM users
  #   QUERY => "SELECT name FROM users"
  #
  # @param [TrueClass, FalseClass] spaced (default=true)
  #   Determines whether returned string has whitespace collapsed or removed
  #
  # @return [String] Receiver with whitespace (including newlines) replaced
  #
  def compress_lines(spaced = true)
    split($/).map { |line| line.strip }.join(spaced ? ' ' : '')
  end

  # Removes leading whitespace from each line, such as might be added when
  # using a HEREDOC string.
  #
  # @return [String] Receiver with leading whitespace removed.
  #
  def unindent
    (other = dup) and other.unindent! and other
  end

  # Bang version of #unindent.
  #
  # @return [String] Receiver with leading whitespace removed.
  #
  def unindent!
    gsub!(/^[ \t]{#{minimum_leading_whitespace}}/, '')
  end

  private

  # Checks each line and determines the minimum amount of leading whitespace.
  #
  # @return [Integer] The number of leading whitespace characters.
  #
  def minimum_leading_whitespace
    whitespace = inject(0) do |indent, line|
      if line.strip.empty?
        indent # Ignore completely blank lines.
      elsif line =~ /^(\s+)/
        (1.0 / $1.length) > indent ? 1.0 / $1.length : indent
      else
        1.0
      end
    end

    whitespace == 1.0 ? 0 : (1.0 / whitespace).to_i
  end

end

# String#compress_lines is extracted from the extlib gem
# ------------------------------------------------------
#
# Copyright (c) 2009 Dan Kubb
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
