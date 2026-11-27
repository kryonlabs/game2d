import * as Native from "controls";
import { WidgetProps } from "kryon/tsx/widget";

export function ControlsChoice(widget: WidgetProps<Native.GameControlsProps>): s32 {
    return Native.GameControlsChoice(widget.session, widget.props);
}

export function StickIndicator(widget: WidgetProps<Native.GameStickIndicatorProps>): void {
    const props = widget.props;
    const radius = props.radius === float32(0) ? float32(40) : props.radius;
    Native.GameStickIndicator(widget.session, props.key, props.state,
        props.heading_x, props.heading_y, radius);
}

export function SwipePreview(widget: WidgetProps<Native.GameSwipePreviewProps>): void {
    Native.GameSwipePreview(widget.session, widget.props.key, widget.props.bounds, widget.props.now);
}
