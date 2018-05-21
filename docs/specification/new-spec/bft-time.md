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
  now, round) and less than or equal to MaxValidTime(last_block_time, now), where:

```go
// wiggle and iota are provided by consensus params.
func MinValidTime(last_block_time, now time.Time, round int) time.Time {
	var minValidTime time.Time = last_block_time.Add(iota)
	if round == 0 {
		minValidTime = maxTime(minValidTime, now.Add(-1*wiggle)
	} else {
		// For all subsequent rounds, we accept any block > last_block_time+iota.
	}
	return minValidTime
}

// wiggle and wiggle_r is provided by consensus params.
func MaxValidTime(last_block_time, round int) time.Time {
	return now.
		Add(wiggle).
		Add(wiggle*wiggle_r*round)
}
```

For `MinValidTime`, we only accept recent blocks (`wiggle`) on the first
round.  This has the effect of slowing down the blockchain progressively for 1
round, as more validator clocks go off sync.  The blockchain's time eventually
catches up to some "reasonable" time as long as correct validators' proposals are accepted in a timely fashion,
assuming the same Byzantine tolerance threshold of 1/3.  TODO: Quantify "reasonable".

For `MaxValidTime`, we accept blocks where the block time is greater than now,
plus some threshold that increases linearly with the round number.
Even if `wiggle_r` were equal 0, as long as +2/3 (by voting power) of correct validators'
clocks are within `wiggle` of each other, it would still work.
The purpose of `wiggle_r` is for graceful degredation when +2/3 non-malicious validators
*aren't* within `wiggle` of each other but are otherwise "correct". 
(Consider an example with 100 equally weighted validators, where 33 are Byzantine,
and one of the remaining 67 validators had a faulty clock that caused it to drift
back more than `wiggle`.) NOTE: `wiggle_r` could be set to something like 0.05, but
requires more analysis and justification.

Subjective time validity is ignored when a Polka or Commit is found, allowing
consensus to progress locally even when the subjective time requirements are not satisfied.
