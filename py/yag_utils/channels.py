# Channel bit flags (re-exported from yag_model) and plotting labels

from yag_model import AL2O3, ALL, Y2O3, YAG, YAM, YAP, Channel, channel_indices

# Matplotlib labels of the five species, indexed by channel index
LABELS = ["$Al_2O_3$", "$Y_2O_3$", "$YAM$", "$YAP$", "$YAG$"]


def labels(mask: int) -> list[str]:
    """Labels of the channels selected by a mask, in the order frames store them."""
    return [LABELS[i] for i in channel_indices(mask)]


__all__ = ["AL2O3", "Y2O3", "YAM", "YAP", "YAG", "ALL", "Channel", "channel_indices", "LABELS", "labels"]
