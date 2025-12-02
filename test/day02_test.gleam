import gleeunit
import gleeunit/should
import day02

pub fn main() {
  gleeunit.main()
}


pub fn is_invalid_part1_11_test() {
  day02.is_invalid_id_part1(11)
  |> should.be_true()
}

pub fn is_invalid_part1_22_test() {
  day02.is_invalid_id_part1(22)
  |> should.be_true()
}

pub fn is_invalid_part1_6464_test() {
  day02.is_invalid_id_part1(6464)
  |> should.be_true()
}

pub fn is_invalid_part1_123123_test() {
  day02.is_invalid_id_part1(123123)
  |> should.be_true()
}

pub fn is_valid_part1_123_test() {
  day02.is_invalid_id_part1(123)
  |> should.be_false()
}

pub fn is_valid_part1_101_test() {
  day02.is_invalid_id_part1(101)
  |> should.be_false()
}


pub fn is_invalid_part2_11_test() {
  day02.is_invalid_id_part2(11)
  |> should.be_true()
}

pub fn is_invalid_part2_111_test() {
  day02.is_invalid_id_part2(111)
  |> should.be_true()
}

pub fn is_invalid_part2_99_test() {
  day02.is_invalid_id_part2(99)
  |> should.be_true()
}

pub fn is_invalid_part2_999_test() {
  day02.is_invalid_id_part2(999)
  |> should.be_true()
}

pub fn is_invalid_part2_12341234_test() {
  day02.is_invalid_id_part2(12341234)
  |> should.be_true()
}

pub fn is_invalid_part2_123123123_test() {
  day02.is_invalid_id_part2(123123123)
  |> should.be_true()
}

pub fn is_invalid_part2_1212121212_test() {
  day02.is_invalid_id_part2(1212121212)
  |> should.be_true()
}

pub fn is_invalid_part2_1111111_test() {
  day02.is_invalid_id_part2(1111111)
  |> should.be_true()
}

pub fn is_valid_part2_123_test() {
  day02.is_invalid_id_part2(123)
  |> should.be_false()
}

pub fn is_valid_part2_1234_test() {
  day02.is_invalid_id_part2(1234)
  |> should.be_false()
}


pub fn example_part1_test() {
  let input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
  
  day02.solve_part1(input)
  |> should.equal(1227775554)
}


pub fn example_part2_test() {
  let input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
  
  day02.solve_part2(input)
  |> should.equal(4174379265)
}


pub fn parse_range_test() {
  day02.parse_range("11-22")
  |> should.equal(Ok(#(11, 22)))
}

pub fn parse_range_large_test() {
  day02.parse_range("1188511880-1188511890")
  |> should.equal(Ok(#(1188511880, 1188511890)))
}