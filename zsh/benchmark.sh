#!/usr/bin/env bash

# benchmark how long it takes to start up zsh
# runs it a bunch of times and calcualtes stats

# check if bc is installed (we need it for math)
if ! command -v bc &> /dev/null; then
  echo "error: bc is not installed. please install it first (brew install bc)"
  exit 1
fi

ITERATIONS=10

echo "benchmarking zsh startup time ($ITERATIONS iterations)..."
echo ""

# store all the timing results here
times=()

# run zsh multiple times and colect the timing data
for i in $(seq 1 $ITERATIONS); do
  echo -n "run $i/$ITERATIONS... "
  
  # time how long it takes to start zsh and exit immediatly
  result=$( (time zsh -i -c exit) 2>&1 | grep real | awk '{print $2}')
  
  # check if zsh actualy ran successfully
  if [[ -z "$result" ]]; then
    echo "failed!"
    continue
  fi
  
  # convert the time format from 0m0.123s to just 0.123
  seconds=$(echo $result | sed 's/0m//;s/s//')
  
  times+=($seconds)
  echo "${seconds}s"
done

# make sure we got at least some results
if [[ ${#times[@]} -eq 0 ]]; then
  echo ""
  echo "error: all benchmark runs failed. something is wrong with your zsh setup"
  exit 1
fi

echo ""
echo "=== statistics ==="

# add up all the times to get avg later
total=0
for time in "${times[@]}"; do
  total=$(echo "$total + $time" | bc)
done

num_results=${#times[@]}
avg=$(echo "scale=3; $total / $num_results" | bc)

# calculate standard deviation
sum_squared_diff=0
for time in "${times[@]}"; do
  diff=$(echo "$time - $avg" | bc)
  squared=$(echo "$diff * $diff" | bc)
  sum_squared_diff=$(echo "$sum_squared_diff + $squared" | bc)
done
variance=$(echo "scale=3; $sum_squared_diff / $num_results" | bc)
stddev=$(echo "scale=3; sqrt($variance)" | bc)

# sort the times so we can get min/max/median
sorted=($(printf '%s\n' "${times[@]}" | sort -n))
min=${sorted[0]}
max=${sorted[-1]}

# calculate median (middle value)
mid=$((num_results / 2))
if (( num_results % 2 == 0 )); then
  median=$(echo "scale=3; (${sorted[$mid-1]} + ${sorted[$mid]}) / 2" | bc)
else
  median=${sorted[$mid]}
fi

echo ""
echo "individual runs:"
for i in "${!times[@]}"; do
  echo "  run $((i+1)): ${times[$i]}s"
done

echo ""
echo "statistics:"
echo "  runs:   $num_results/$ITERATIONS"
echo "  min:    ${min}s"
echo "  max:    ${max}s"
echo "  mean:   ${avg}s"
echo "  median: ${median}s"
echo "  stddev: ${stddev}s"
