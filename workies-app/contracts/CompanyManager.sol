// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./ISoulboundNFT.sol";
import "./ISoulboundNFTReceiver.sol";
import "./TextResolver.sol";
import "./PaymentManager.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CompanayManager is PaymentManager, ISoulboundNFT, Context, Ownable, TextResolver {
    
    using Address for address;
    using Strings for uint256;
    
    // Token name
    string private _name;
    
    // Token symbol
    string private _symbol;
    
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    mapping(uint256 => string) private _tokenURIs;

    uint256 private employeeNumber;
    
    /**
    * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
    */
    constructor(string memory name_, string memory symbol_, ISuperToken _payrollToken, ISuperfluid _host) PaymentManager(_payrollToken,_host) {
        _name = name_;
        _symbol = symbol_;
    }
    
    /**
     * @dev See {ISoulboundNFT-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "SoulboundNFT: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {ISoulboundNFTMetadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {ISoulboundNFTMetadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public virtual onlyOwner {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

	/**
     * @dev See {ISoulboundNFTMetadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

	/**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

	/**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {ISoulboundNFTReceiver-onSoulboundNFTReceived}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeMint(address to, uint256 tokenId, int96 montlyPayment) external virtual onlyOwner addEmployee(to,montlyPayment) {
        _safeMint(to, tokenId, "");
    }

	/**
     * @dev Same as {xref-SoulboundNFT-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {ISoulboundNFTReceiver-onSoulboundNFTReceived} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnSoulboundNFTReceived(address(0), to, tokenId, _data),
            "SoulboundNFT: transfer to non SoulboundNFTReceiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual onlyOwner {
        require(to != address(0), "SoulboundNFT: mint to the zero address");
        require(!_exists(tokenId), "SoulboundNFT: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual onlyOwner {
        address owner = CompanayManager.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to invoke {ISoulboundNFTReceiver-onSoulboundNFTReceived} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnSoulboundNFTReceived(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try ISoulboundReceiver(to).onSoulboundReceived(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == ISoulboundReceiver.onSoulboundReceived.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Soulbound: transfer to non SoulboundReceiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
