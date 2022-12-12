import React from "react";
import {SquareButton} from './SquareButton';
import {ButtonLabel} from './ButtonLabel';
import styled from "styled-components";

export interface NumberButtonProps {
    label: string,
    row: number,
    column: number,
    width? :number,
    onClick?: () => void,
} 

const StyledSquareButton = styled(SquareButton)`
    background: ${props => props.theme.colors.background.light};
    ${props => props.width !== 1 ? "aspect-ratio: auto;" : ""}
`;

class NumberButton extends React.Component<NumberButtonProps> {
    render() {
        return (
            <StyledSquareButton row={this.props.row} column={this.props.column} width={this.props.width} onClick={this.props.onClick || (() => {})}>
                <ButtonLabel>
                    {this.props.label}
                </ButtonLabel>
            </StyledSquareButton>
        )
    }
}

export default NumberButton;