# BFT time in Tendermint 

Tendermint provides a deterministic, Byzantine fault-tolerant, source of time.
In the context of Tendermint, time denotes UNIX time in milliseconds, i.e.,
corresponds to the number of milliseconds since January 1, 1970.

Time in Tendermint is defined with the Time field of the block header. 
It satisfies the following property:

- **Time Monotonicity**: Time is monotonically increasing, i.e., given 
a header H1 for height h1 and a header H2 for height `h2 = h1 + 1`, `H1.Time < H2.Time`.

Beyond satisfying time monotinicity, Tendermint also checks the following
property, but only when signing a prevote for a block:

- **Subjective Time Validity**: Time is greater than MinValidTime(last_block_time,
  now, round) and less than or equal to MaxValidTime(last_block_time, now, round), where:

```go
// wiggle_dur and iota are provided by consensus params.
func MinValidTime(last_block_time, now time.Time, round int) time.Time {
	var minValidTime time.Time = last_block_time.Add(iota)
	if round == 0 {
		minValidTime = maxTime(minValidTime, now.Add(-1*wiggle_dur)
	} else {
		// For all subsequent rounds, we accept any block > last_block_time+iota.
	}
	return minValidTime
}

// wiggle_dur and wiggle_r are provided by consensus params.
func MaxValidTime(last_block_time, now time.Time, round int) time.Time {
	return now.
		Add(wiggle_dur).
		Add(now.Subtract(last_block_time)*wiggle_r*round)
}
```

For `MinValidTime`, we only accept recent blocks (`wiggle_dur`) on the first
round.  This has the effect of slowing down the blockchain progressively for 1
round, as more validator clocks go off sync.  Otherwise, the only remaining
restriction is that each block time must increment by `iota`.  Block time
eventually catches up to some "reasonable time" as long as correct validators'
proposals are accepted in a timely fashion.

For `MaxValidTime`, we accept blocks where the block time is greater than now, where
the tolerance increases linearly with each round number by ratio `wiggle_r`.
This prevents the clock from jumping forward too quickly, which cannot be undone
as the block time must be monotonic.

Subjective time validity is ignored when a Polka or Commit is found, allowing
consensus to progress locally even when the subjective time requirements are not satisfied.
