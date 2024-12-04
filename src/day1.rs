use std::collections::HashMap;

use crate::Day;

pub struct Day1 {
    lhs: Vec<i32>,
    rhs: Vec<i32>,
}

impl Day for Day1 {
    fn new(input: &str) -> Self {
        let (lhs, rhs) = parse_input(input);
        Day1 { lhs, rhs }
    }

    fn part1(&self) -> String {
        self.lhs
            .iter()
            .zip(self.rhs.iter())
            .map(|(a, b)| (a - b).abs())
            .sum::<i32>()
            .to_string()
    }

    fn part2(&self) -> String {
        let mut count = HashMap::new();

        self.rhs
            .iter()
            .for_each(|b| *count.entry(b).or_insert(0) += 1);

        self.lhs
            .iter()
            .map(|a| a * count.get(a).unwrap_or(&0))
            .sum::<i32>()
            .to_string()
    }
}

fn parse_input(input: &str) -> (Vec<i32>, Vec<i32>) {
    let mut lhs = vec![];
    let mut rhs = vec![];

    input.lines().for_each(|line| {
        let parts: Vec<_> = line.split_whitespace().collect();
        lhs.push(parts[0].parse().unwrap());
        rhs.push(parts[1].parse().unwrap());
    });

    lhs.sort();
    rhs.sort();

    (lhs, rhs)
}
