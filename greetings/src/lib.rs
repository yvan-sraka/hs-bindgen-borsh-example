use borsh::{from_slice, to_vec, BorshDeserialize, BorshSerialize};
use std::{ffi::CString, str::FromStr};

#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
struct A {
    x: u64,
    y: String,
}

// TODO: Shouldn't this be a fixed size..?
#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
struct B {
    x: u64,
}

use hs_bindgen::*;

struct User {
    name: String,
    age: u16,
}

#[hs_bindgen(hello :: CString -> IO ())]
fn hello(name: &str) {
    println!("Hello, {name}!");
}

// FIXME: Need to figure out a way to send over structs
#[hs_bindgen(greetings ::  IO (Ptr CUChar))]
fn greetings() -> *const u8 {
    // TODO: See if I can deserailize this in haskell
    let a = A {
        x: 3301,
        y: "liber primus".to_string(),
    };
    let mut encoded_a = to_vec(&a).unwrap();
    // FIXME: Figure out how to convert a usize to bytes
    let s: u8 = encoded_a.len().try_into().unwrap();
    println!("Size of encoded is: {s}");
    // TODO: For now, I'll put the size of the bincode at 0.?
    let mut to_send = vec![s]; // encode the size of the vector as the first byte
    let ptr = to_send.as_mut_ptr();
    to_send.append(&mut encoded_a);
    // NOTE:
    // Rust needs to forget these two values
    // so the destructor never runs - Haskell will now manage these vectors
    std::mem::forget(ptr);
    std::mem::forget(to_send);

    return ptr;
}

// Send over a C pointer and a length using Haskell..?
//
#[hs_bindgen(send_arr ::  IO (Ptr CUChar))]
#[no_mangle]
fn send_arr() -> *const u8 {
    let test = [0, 1, 2, 3];
    let b = Box::new(test);
    return Box::into_raw(b) as *mut _;
}

#[cfg(test)]
mod tests {
    // Note this useful idiom: importing names from outer (for mod tests) scope.
    use super::*;

    #[test]
    fn my_test() {
        // let a = B { x: 3301 };

        let a = A {
            x: 3301,
            y: "liber primus".to_string(),
        };
        let encoded_a = to_vec(&a).unwrap();
        println!("Encoded A is: {:?}", encoded_a);
        assert!(false);
        // assert_eq!(add(1, 2), 3);
    }
}
