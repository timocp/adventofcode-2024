use std::fs;

mod day1;

trait Day {
    fn new(input: &str) -> Self;
    fn part1(&self) -> String;
    fn part2(&self) -> String;
}

fn main() {
    run(1);
}

fn run(num: i32) {
    let filename = format!("input/day{}.txt", num);
    let input = fs::read_to_string(&filename).unwrap();
    match num {
        1 => {
            let d = day1::Day1::new(&input);
            println!("Day {} part 1: {}", num, d.part1());
            println!("Day {} part 2: {}", num, d.part2());
        }
        _ => eprintln!("{}: Not implemented", num),
    };
}
