from brownie import AdvancedCollectible, config, network, accounts

from scripts.helpful_scripts import get_breed

import time


def main():
    dev = accounts.add(config["wallets"]["from_key"])
    contract = AdvancedCollectible[-1]
    tx = contract.createCollectible("jj", {"from": dev})

    tx.wait(5)

    while True:
        random_num = contract.randomNum()
        if random_num != 0:
            print("Finally received random num:", random_num)
            break
        else:
            print("Random number is not here yet... Waiting another 5 sn")
            time.sleep(5)

    requestId = tx.events["requestedCollectible"]["requestId"]
    token_id = contract.requestIdToTokenId(requestId)
    breed = get_breed(contract.tokenIdToBreed(token_id))
    print("Random numebr is ", contract.randomNum())
    print("Dog breed of tokenId {} is {}".format(token_id, breed))
