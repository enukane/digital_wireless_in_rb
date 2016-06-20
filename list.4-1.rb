
class List41_BPSK
  SNR_STEP=10
  L=10000

  def randU
    return rand()
  end

  def randN
    r = Math.sqrt(-2.0 * Math.log(randU()))
    t = 2.0 * Math::PI * randU()
    return r * Math.sin(t)
  end

  def rand_data len
    data = []
    0.upto(len - 1) do |n|
      x = randU()
      if (x >= 0.5)
        data << 1.0
      else
        data << 0.0
      end
    end

    return data
  end

  def awgn len, pn
    data = Array.new(len).map{|elm|
      Complex(
        randN() * Math.sqrt(pn/2.0),
        randN() * Math.sqrt(pn/2.0)
      )
    }
    return data
  end

  def snrdb_to_noisepower c_db
    return 10 ** ((-1) * c_db / 10.0)
  end

  def bpsk_modulate tx_data
    raise "tx_data empty" if tx_data.nil? or tx_data.empty?

    tx_symbol = tx_data.map{|tx_datum|
      Complex(
        0,
        tx_datum - 0.5 * 2.0
      )
    }

    return tx_symbol
  end

  def vector_sum v0, v1
    raise "size unmatched" if v0.length != v1.length
    v_sum = []

    0.upto(v0.length - 1) do |n|
      v_sum << Complex(
        v0[n].real + v1[n].real,
        v0[n].imag + v1[n].imag
      )
    end

    return v_sum;
  end

  def bpsk_demodulate rx_symbol, len
    rx_data = rx_symbol.map{|elm|
      if elm.imag > 0
        1
      else
        0
      end
    }

    return rx_data
  end

  def ber_calculate tx_data, rx_data
    raise "size unmatched" if tx_data.length != rx_data.length

    sum = 0
    0.upto(tx_data.length - 1) do |n|
      sum += (tx_data[n] - rx_data[n]).abs
    end

    return sum.to_f/tx_data.length
  end

  def ber_print snr_step, snrdb, ber
    0.upto(snr_step - 1) do |n|
      printf "%f [dB] BER = %f\n", snrdb[n], ber[n]
    end
  end

  def main
    snrdb = []
    ber = []

    0.upto(@snr_step - 1){|n| snrdb[n] = n.to_f}

    0.upto(@snr_step - 1) do |n|
      srand(Time.now.to_i)

      tx_data = rand_data(L)

      tx_symbol = bpsk_modulate(tx_data)

      noise = awgn(L, snrdb_to_noisepower(snrdb[n]))

      rx_symbol = vector_sum(tx_symbol, noise)

      rx_data = bpsk_demodulate(rx_symbol, L)

      ber[n] = ber_calculate(tx_data, rx_data)
    end

    ber_print(@snr_step, snrdb, ber)
  end

  def initialize snr_step
    @snr_step = snr_step || SNR_STEP
  end
end

list41 = List41_BPSK.new((ARGV.shift || List41_BPSK::SNR_STEP).to_i)
list41.main

