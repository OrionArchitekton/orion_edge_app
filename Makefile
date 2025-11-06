.PHONY: memo-recall help

help:
	@echo "Available targets:"
	@echo "  memo-recall    Generate Slack-ready memory recall summary"

memo-recall:
	@bash scripts/memo_recall.sh

