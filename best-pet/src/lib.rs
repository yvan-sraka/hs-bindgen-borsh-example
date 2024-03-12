use borsh::{BorshDeserialize, BorshSerialize};
use hs_bindgen::*;

#[derive(BorshSerialize, BorshDeserialize, PartialEq, Debug)]
enum Pet { Cat, Dog }

#[hs_bindgen(best_pet :: IO (Ptr CUChar))]
fn best_pet() -> *const u8 {
    let nya = Pet::Cat;
    let mut data = borsh::to_vec(&nya).unwrap();
    data.insert(0, data.len().try_into().unwrap());
    let ptr = data.as_ptr();
    std::mem::forget(data);
    return ptr;
}
