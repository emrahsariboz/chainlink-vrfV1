from brownie import AdvancedCollectible, accounts, network, config
from scripts.helpful_scripts import fund_advanced_collectible


def main():
    deploy()


def deploy():
    dev = accounts.add(config["wallets"]["from_key"])

    contract = AdvancedCollectible.deploy(
        config["networks"][network.show_active()]["vrf_coordinator"],
        config["networks"][network.show_active()]["link_token"],
        config["networks"][network.show_active()]["keyHash"],
        {"from": dev},
    )

    fund_advanced_collectible(contract)

    return contract
